@secure()
param kubeConfig string

import 'kubernetes@1.0.0' with {
  kubeConfig: kubeConfig
  namespace: 'default'
}

param location string

param serviceConfig {
  image: string
  dnsPrefix: string
  port: int
}

@secure()
param appConfig {
  openAiEndpoint: string
  apiKey: string
}

var appName = 'openai-test'
var build = {
  version: 'latest'
  image: serviceConfig.image
  port: serviceConfig.port
}

resource apiDeploy 'apps/Deployment@v1' = {
  metadata: {
    name: appName
  }
  spec: {
    selector: {
      matchLabels: {
        app: appName
        version: build.version
      }
    }
    replicas: 1
    template: {
      metadata: {
        labels: {
          app: appName
          version: build.version
        }
      }
      spec: {
        containers: [
          {
            name: appName
            image: build.image
            ports: [
              {
                containerPort: build.port
              }
            ]
            env: [
              {
                name: 'OPENAI_ENDPOINT'
                value: appConfig.openAiEndpoint
              }
              {
                name: 'API_KEY'
                value: appConfig.apiKey
              }
            ]
          }
        ]
      }
    }
  }
}

resource apiService 'core/Service@v1' = {
  metadata: {
    name: appName
    annotations: {
      'service.beta.kubernetes.io/azure-dns-label-name': serviceConfig.dnsPrefix
    }
  }
  spec: {
    type: 'LoadBalancer'
    ports: [
      {
        port: build.port
      }
    ]
    selector: {
      app: appName
    }
  }
}

var normalizedLocation = toLower(replace(location, ' ', ''))

output endpoint string = 'http://${serviceConfig.dnsPrefix}.${normalizedLocation}.cloudapp.azure.com'
