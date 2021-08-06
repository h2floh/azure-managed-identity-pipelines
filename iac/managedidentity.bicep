param location string

resource msid 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'id-self-hosted-agent'
  location: location
}

output managedId string = msid.id
output objectId string = msid.properties.principalId
