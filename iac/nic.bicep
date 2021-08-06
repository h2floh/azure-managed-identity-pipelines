  
param vmName string
param nicNumber int = 0
param location string
param subnetId string

var nicName = '${vmName}-nic-${nicNumber}'
var pipName = '${vmName}-pip-${nicNumber}'

resource pip 'Microsoft.Network/publicIPAddresses@2020-07-01' = {
  name: pipName
  location: location
  tags: {}
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: pip.id 
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}

output nicId string = nic.id
