param baseName string
param dnsPrefix string
param linuxAdminUsername string
param sshRSAPublicKey string
@secure()
param apiKey string

#disable-next-line no-loc-expr-outside-params
var location = resourceGroup().location

module aks 'modules/aks.bicep' = {
  name: '${deployment().name}-aks'
  params: {
    aksConfig: {
      adminPublicKey: sshRSAPublicKey
      adminUsername: linuxAdminUsername
      clusterName: baseName
      dnsPrefix: dnsPrefix
    }
    location: location
  }
}

module openAi 'modules/openai.bicep' = {
  name: '${deployment().name}-openai'
  params: {
    location: location
    openAiSettings: {
      accountName: '${baseName}${uniqueString(resourceGroup().id)}'
      identity: aks.outputs.identity
    }
  }
}

resource aksRef 'Microsoft.ContainerService/managedClusters@2022-04-01' existing = {
  name: baseName
}

module kubernetes './modules/kubernetes.bicep' = {
  name: '${deployment().name}-kubernetes'
  params: {
    kubeConfig: aksRef.listClusterAdminCredential().kubeconfigs[0].value
    serviceConfig: {
      image: 'ghcr.io/anthony-c-martin/openai-test:main'
      port: 80
    }
    appConfig: {
      openAiEndpoint: openAi.outputs.endpoint
      apiKey: apiKey
    }
  }
  dependsOn: [aks]
}

var dnsLabel = kubernetes.outputs.dnsLabel
var normalizedLocation = toLower(replace(location, ' ', ''))

output endpoint string = 'http://${dnsLabel}.${normalizedLocation}.cloudapp.azure.com'
