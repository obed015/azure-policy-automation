// policies/policy.bicep
targetScope = 'subscription'

param policyName string = 'Audit-Public-Network-Access'
param policyDisplayName string = 'Audit Public Network Access'
param policyDescription string = 'Audits resources that allow public network access.'

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Network'
    }
    policyRule: {
      if: {
        field: 'Microsoft.Storage/storageAccounts/networkAcls.defaultAction'
        equals: 'Allow'
      }
      then: {
        effect: 'audit'
      }
    }
  }
}

output policyDefinitionId string = policyDefinition.id
