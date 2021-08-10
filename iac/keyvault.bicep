param location string
param objectId string
param subnetId string
param vnetId string 
param salt string = utcNow()

var kvName = 'kv${uniqueString(salt)}'
var vaultNamePE = 'kv${uniqueString(salt)}-pe'
var kvPrivateDnsName = 'privatelink.vaultcore.azure.net'
var dnsZoneName = 'privatelink-vaultcore-azure-net'

// Main Resource
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: kvName
  location: location
  tags: {}
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: objectId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
    networkAcls: {
      defaultAction: 'Deny'
    }
  }
}

// TestSecret
resource kvSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${kvName}/somekey'
  tags: {}
  properties: {
    value: 'somevalue'
    contentType: 'string'
  }
  dependsOn: [
    keyVault
  ]
}

// Private Endpoint for Resource
resource vaultPE 'Microsoft.Network/privateEndpoints@2020-07-01' = {
  name: vaultNamePE
  location: location
  tags: {}
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            'vault'
          ]
          requestMessage: 'bicep'
        }
        name: vaultNamePE
      }
    ]
  }
}

// Private DNS Entry for resource
resource kv_private_dns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: kvPrivateDnsName
  tags: {}
  location: 'global'
  properties: {}
}

// Linking Private DNS and VNET
resource kv_private_dns_virtualNetworkLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${kvPrivateDnsName}/vnl'
  tags: {}
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
  dependsOn: [
    kv_private_dns
  ]
}

// Linking Private Endpoint with Private DNS
resource kv_private_endpoint_dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-07-01' = {
  name: '${vaultNamePE}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: dnsZoneName
        properties: {
          privateDnsZoneId: kv_private_dns.id
        }
      }
    ]
  }
  dependsOn: [
    kv_private_dns
    vaultPE
  ]
}

output kv_name string = keyVault.name
