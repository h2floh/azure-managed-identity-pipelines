targetScope = 'subscription'

param resourceGroupName string = 'self-hosted-agent-rg'
param location string = 'koreacentral'
param username string
param sshPublicKey string
param salt string = utcNow()
@secure()
param AzDOPATtoken string
param AzDOVSTSAccountUrl string
param AzDOAgentPool string
param GitHubRepoURL string
@secure()
param GitHubToken string

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

module managedid 'managedidentity.bicep' = {
  name: 'managedidentity'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
  }
  dependsOn: [
    resourceGroups
  ]
}

module kv './keyvault.bicep' = {
  name: 'kv'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    subnetId: network.outputs.subnetIdServices
    vnetId: network.outputs.vnetId
    objectId: managedid.outputs.objectId
    salt: salt
  }
  dependsOn: [
    resourceGroups
  ]
}

module acr './containerregistry.bicep' = {
  name: 'acr'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    subnetId: network.outputs.subnetIdServices
    vnetId: network.outputs.vnetId
    principalId: managedid.outputs.objectId
    salt: salt
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
    subnetId: network.outputs.subnetIdBuildAgents
    username: username
    sshPublicKey: sshPublicKey
    managedId: managedid.outputs.managedId
    AzDOAgentPool: AzDOAgentPool
    AzDOPATtoken: AzDOPATtoken
    AzDOVSTSAccountUrl: AzDOVSTSAccountUrl
    GitHubRepoURL: GitHubRepoURL
    GitHubToken: GitHubToken
  }
  dependsOn: [
    resourceGroups
  ]
}

