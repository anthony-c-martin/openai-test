param location string
param aksConfig {
  clusterName: string
  dnsPrefix: string
  adminUsername: string
  adminPublicKey: string
}

var osDiskSizeGB = 0
var agentCount = 1
var agentVmSize = 'Standard_B2s'

resource aks 'Microsoft.ContainerService/managedClusters@2022-04-01' = {
  name: aksConfig.clusterName
  location: location
  properties: {
    dnsPrefix: aksConfig.dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVmSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: aksConfig.adminUsername
      ssh: {
        publicKeys: [
          {
            keyData: aksConfig.adminPublicKey
          }
        ]
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output clusterName string = aks.name
output identity {
  tenantId: string
  principalId: string
} = aks.identity
