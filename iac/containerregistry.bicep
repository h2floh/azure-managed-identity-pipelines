param location string
param subnetId string
param vnetId string
param principalId string
param salt string = utcNow()

var acrName = 'acr${uniqueString(salt)}'
var acrNamePE = 'acr${uniqueString(salt)}-pe'
var acrPrivateDnsName = 'privatelink.azurecr.io'
var dnsZoneName = 'privatelink-azurecr-io'

// Main Resource
resource acr 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  name: acrName
  location: location
  tags: {}
  sku: {
    name: 'Premium'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

// RBAC Setting for Managed Identity
resource acr_rbac 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(acr.id)
  scope: acr
  properties: {
    // Contributor
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalId: principalId
  }
}

// Private Endpoint for Resource
resource acrPE 'Microsoft.Network/privateEndpoints@2020-07-01' = {
  name: acrNamePE
  location: location
  tags: {}
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: acr.id
          groupIds: [
            'registry'
          ]
          requestMessage: 'bicep'
        }
        name: acrNamePE
      }
    ]
  }
}

// Private DNS Entry for resource
resource acr_private_dns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: acrPrivateDnsName
  tags: {}
  location: 'global'
  properties: {}
}

// Linking Private DNS and VNET
resource acr_private_dns_virtualNetworkLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${acrPrivateDnsName}/vnl'
  tags: {}
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
  dependsOn: [
    acr_private_dns
  ]
}

// Linking Private Endpoint with Private DNS
resource acr_private_endpoint_dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-07-01' = {
  name: '${acrNamePE}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: dnsZoneName
        properties: {
          privateDnsZoneId: acr_private_dns.id
        }
      }
    ]
  }
  dependsOn: [
    acr_private_dns
    acrPE
  ]
}
