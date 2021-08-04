targetScope = 'subscription'

param resourceGroupName string = 'self-hosted-agent-rg'
param location string = 'koreacentral'
param username string
param sshPublicKey string

module resourceGroups './resourceGroup.bicep' = {
  name: resourceGroupName
  params: {
    location: location
    name: resourceGroupName
  }
}

module network './network.bicep' = {
  name: 'network'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
  }
  dependsOn: [
    resourceGroups
  ]
}


module buildagent './buildagent.bicep' = {
  name: 'buildagent'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    subnetId: network.outputs.subnetid
    username: username
    sshPublicKey: sshPublicKey
  }
  dependsOn: [
    resourceGroups
  ]
}

