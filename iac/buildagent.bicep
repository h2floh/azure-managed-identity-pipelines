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
param managedId string
param AzDOPATtoken string
param AzDOVSTSAccountUrl string
param AzDOTeamProject string
param AzDODeploymentGroup string
param GitHubRepoURL string
param GitHubToken string

// Create the nic
module nic './nic.bicep' = {
  name: '${vmName}-nic'
  params: {
    vmName: vmName
    location: location
    subnetId: subnetId
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: vmName
  location: location
  identity: {
    type: 'UserAssigned'
    // this is strange but it is what it is https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/qs-configure-template-windows-vm#assign-a-user-assigned-managed-identity-to-an-azure-vm
    userAssignedIdentities: {
      '${managedId}': {}
    }
  }
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

// Post Deployment Script && GitHub Actions Runner
resource post_deployment 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${vmName}/config-app'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      skipDos2Unix: false
    }
    protectedSettings: {
      commandToExecute: 'bash postDeployment.sh ${username} ${GitHubRepoURL} ${GitHubToken}'
      fileUris: [
        'https://raw.githubusercontent.com/h2floh/azure-managed-identity-pipelines/h2floh/init/iac/postDeployment.sh'
        'https://raw.githubusercontent.com/h2floh/azure-managed-identity-pipelines/h2floh/init/iac/githubActionsRunner.sh'
      ]
    }
  }
  dependsOn: [
    vm
  ]
}

// Azure Pipelines Agent
resource azdo_agent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${vmName}/TeamServicesAgentLinux'
  location: location
  properties: {
    publisher: 'Microsoft.VisualStudio.Services'
    type: 'TeamServicesAgentLinux'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {
      VSTSAccountUrl: AzDOVSTSAccountUrl
      TeamProject: AzDOTeamProject
      DeploymentGroup: AzDODeploymentGroup
      AgentName: vmName
    }
    protectedSettings: {
      PATToken: AzDOPATtoken
    }
  }
  dependsOn: [
    vm
  ]
}


output vmId string = vm.id
