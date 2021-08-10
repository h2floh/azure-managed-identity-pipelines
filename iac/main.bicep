targetScope = 'subscription'

@description('Name of the resource group')
param resourceGroupName string = 'self-hosted-agent-rg'
@description('Azure region for all services')
param location string = 'koreacentral'
@description('Username for the VM')
param username string
@description('Public SSH Key for user')
param sshPublicKey string
@description('Salt to generate globally unique service names')
param salt string = utcNow()
@description('Azure DevOps PAT Token with Agent Pools manage scope')
@secure()
param AzDOPATtoken string
@description('Azure DevOps Account URL https://dev.azure.com/<youraccount>')
param AzDOAccountUrl string
@description('Azure DevOps Pipeline Pool e.g. \'Default\'')
param AzDOAgentPool string
@description('Your GitHub Repo URL e.g. https://github.com/<youraccount>/<yourrepo>')
param GitHubRepoURL string
@description('Your GitHub Runner Token - from Repo Settings -> Actions -> Runners -> Add Runner')
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
    AzDOAccountUrl: AzDOAccountUrl
    GitHubRepoURL: GitHubRepoURL
    GitHubToken: GitHubToken
  }
  dependsOn: [
    resourceGroups
  ]
}

output acr_name string = acr.outputs.acr_name
output kv_name string = kv.outputs.kv_name
