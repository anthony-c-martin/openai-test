@secure()
param kubeConfig string

import 'kubernetes@1.0.0' with {
  kubeConfig: kubeConfig
  namespace: 'default'
}

var build = {
  name: 'openai-test'
  version: 'latest'
  image: 'ghcr.io/anthony-c-martin/openai-test:main'
  port: 80
}

resource buildDeploy 'apps/Deployment@v1' = {
  metadata: {
    name: build.name
  }
  spec: {
    selector: {
      matchLabels: {
        app: build.name
        version: build.version
      }
    }
    replicas: 1
    template: {
      metadata: {
        labels: {
          app: build.name
          version: build.version
        }
      }
      spec: {
        containers: [
          {
            name: build.name
            image: build.image
            ports: [
              {
                containerPort: build.port
              }
            ]
          }
        ]
      }
    }
  }
}

resource buildService 'core/Service@v1' = {
  metadata: {
    name: build.name
    annotations: {
      'service.beta.kubernetes.io/azure-dns-label-name': build.name
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
      app: build.name
    }
  }
}

output dnsLabel string = build.name
