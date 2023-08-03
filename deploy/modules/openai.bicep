param location string

param openAiSettings {
  accountName: string
  identity: {
    tenantId: string
    principalId: string
  }
}

var config = {
  name: openAiSettings.accountName
  sku: 'S0'
  maxConversationTokens: '2000'
  model: {
    name: 'gpt-35-turbo'
    version: '0301'
    deployment: {
      name: 'chatmodel'
    }
  }
}

resource openAiAccount 'Microsoft.CognitiveServices/accounts@2022-12-01' = {
  name: config.name
  location: location
  sku: {
    name: config.sku
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: config.name
    publicNetworkAccess: 'Enabled'
  }
}

resource openAiModelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2022-12-01' = {
  parent: openAiAccount
  name: config.model.deployment.name
  properties: {
    model: {
      format: 'OpenAI'
      name: config.model.name
      version: config.model.version
    }
    scaleSettings: {
      scaleType: 'Standard'
    }
  }
}

resource cognitiveServicesRole 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope: subscription()
  name: 'a97b65f3-24c7-4388-baec-2e87135dc908'
}

resource serviceRoleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: openAiAccount
  name: guid(cognitiveServicesRole.id, openAiSettings.identity.principalId, openAiAccount.id)
  properties: {
    roleDefinitionId: cognitiveServicesRole.id
    principalId: openAiSettings.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output endpoint string = openAiAccount.properties.endpoint
