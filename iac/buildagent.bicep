param location string
param subnetId string
param vmName string = 'self-hosted-agent'
param offer string = '0001-com-ubuntu-server-focal'
param publisher string = 'Canonical'
param ubuntuOsSKU string = '20_04-lts'
param ubuntuOsVersion string = '20.04.202107200'
param osDiskType string = 'Standard_LRS'
param vmSize string = 'Standard_B1s'
param username string
param sshPublicKey string

// Create the nic
module nic './nic.bicep' = {
  name: '${vmName}-nic'
  params: {
    vmName: vmName
    location: location
    subnetId: subnetId
  }
}

resource vm_small 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: publisher
        offer: offer
        sku: ubuntuOsSKU
        version: ubuntuOsVersion
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: username
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              keyData: sshPublicKey
              path: '/home/${username}/.ssh/authorized_keys'
            }
          ]
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.outputs.nicId
        }
      ]
    }
  }
}
