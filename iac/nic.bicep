  
param vmName string
param nicNumber int = 0
param location string
param subnetId string

var nicName = '${vmName}-nic-${nicNumber}'

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
