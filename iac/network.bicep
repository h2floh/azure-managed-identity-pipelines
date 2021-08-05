param location string

resource network 'Microsoft.Network/virtualNetworks@2020-07-01' = {
  name: 'vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-build-agents'
        properties: {
          addressPrefix: '192.168.83.0/24'
        }
      }
      {
        name: 'snet-services'
        properties: {
          addressPrefix: '192.168.88.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }   
}

output vnetId string = network.id
output subnetIdBuildAgents string = network.properties.subnets[0].id
output subnetIdServices string = network.properties.subnets[1].id
