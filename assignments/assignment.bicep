// assignments/assignment.bicep
targetScope = 'subscription'

@description('Policy initiative ID to assign.')
param initiativeId string

@description('Display name of the initiative assignment.')
param displayName string = 'Cloud-Governance-Baseline-Sub'

resource initiativeAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'cloud-governance-baseline-assignment'
  properties: {
    displayName: displayName
    policyDefinitionId: initiativeId
    enforcementMode: 'Default'
    // parameters: {}        // add if your policies need parameters
  }
}
