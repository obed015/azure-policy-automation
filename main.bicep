// main.bicep
// Root deployment for:
//  - Policy definition (Audit Public Network Access)
//  - Initiative (Cloud Governance Baseline)
//  - Assignment at subscription scope
//  - Policy deny alert wired to LAW + Action Group
//  - Cloud Policy Compliance workbook

targetScope = 'subscription'

// ---------------------- PARAMETERS ----------------------
@description('Subscription where the initiative will be assigned.')
param targetSubscriptionId string = subscription().subscriptionId

@description('Display name for the initiative assignment.')
param assignmentDisplayName string = 'Cloud-Governance-Baseline-Sub'

// LAW + Action Group naming
@description('Resource group containing the Log Analytics workspace.')
param workspaceRgName string = 'rg-governance-core'

@description('Name of the Log Analytics workspace.')
param workspaceName string = 'law-governance'

@description('Resource group containing the Action Group.')
param actionGroupRgName string = 'rg-governance-core'

@description('Name of the Action Group used for policy alerts.')
param actionGroupName string = 'policy-alerts'

// ---------------------- VARIABLES -----------------------
// Build resource IDs from subscription + RG + name
var workspaceId = resourceId(
  subscription().subscriptionId,
  workspaceRgName,
  'Microsoft.OperationalInsights/workspaces',
  workspaceName
)

var actionGroupId = resourceId(
  subscription().subscriptionId,
  actionGroupRgName,
  'Microsoft.Insights/actionGroups',
  actionGroupName
)

// ---------------------- MODULES -------------------------
// 1. Policy definition: Audit Public Network Access
module policy './policies/policy.bicep' = {
  name: 'policy-audit-public-network-access'
  params: {}
}

// 2. Initiative built from the policy definition
module initiative './policies/initiative.bicep' = {
  name: 'cloud-governance-initiative'
  params: {
    policyDefinitions: [
      policy.outputs.policyDefinitionId
    ]
  }
}

// 3. Assign the initiative at subscription scope
module assignment './assignments/assignment.bicep' = {
  name: 'cloud-governance-initiative-assignment'
  scope: subscription(targetSubscriptionId)
  params: {
    initiativeId: initiative.outputs.initiativeId
    displayName: assignmentDisplayName
  }
}

// 4. Create the Policy-Deny alert wired to LAW + Action Group
module alert './alerts/policy-deny-alert.bicep' = {
  name: 'policy-deny-activity-alert'
  scope: resourceGroup(workspaceRgName)
  params: {
    workspaceId:  workspaceId
    actionGroupId: actionGroupId
  }
}

// 5. Cloud Policy Compliance workbook
module policyWorkbook './workbooks/policy-dashboard.bicep' = {
  name: 'cloud-policy-compliance-workbook'
  scope: resourceGroup(workspaceRgName)
  params: {
    // MUST MATCH "id" IN cloud-policy-compliance.json
    workbookName: '220a482d-b80e-4538-8938-970f584ef2f5'
    workbookDisplayName: 'Cloud Policy Compliance Dashboard'
    workbookJson: loadTextContent('./workbooks/cloud-policy-compliance.json')
  }
}
