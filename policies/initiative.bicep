// policies/initiative.bicep
targetScope = 'subscription'

@description('Policy definition IDs to include in the initiative.')
param policyDefinitions array

@description('Name of the initiative (policy set definition).')
param initiativeName string = 'Cloud-Governance-Baseline'

@description('Display name of the initiative.')
param initiativeDisplayName string = 'Cloud Governance Baseline'

@description('Description of the initiative.')
param initiativeDescription string = 'Collection of governance policies such as auditing public network access.'

resource initiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    displayName: initiativeDisplayName
    description: initiativeDescription
    policyType: 'Custom'
    metadata: {
      category: 'Network'
    }
    policyDefinitions: [
      for p in policyDefinitions: {
        policyDefinitionId: p
      }
    ]
  }
}

output initiativeId string = initiative.id
