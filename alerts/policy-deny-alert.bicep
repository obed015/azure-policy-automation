// alerts/policy-deny-alert.bicep

@description('Resource ID of the Log Analytics workspace used as alert scope.')
param workspaceId string

@description('Resource ID of the Action Group that receives the alert.')
param actionGroupId string

resource policyDenyAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'Policy-Deny-Activity-Detection'
  location: 'global'
  properties: {
    description: 'Alert when policy-based DENY actions occur'
    severity: 2
    enabled: true
    autoMitigate: true

    scopes: [
      workspaceId
    ]

    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'

    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'PolicyDenyActivityCriteria'
          metricNamespace: 'AzureActivity'
          metricName: 'PolicyDenyCount'
          timeAggregation: 'Count'
          operator: 'GreaterThan'
          threshold: 0
          skipMetricValidation: true
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }

    actions: [
      {
        actionGroupId: actionGroupId
        webHookProperties: {}
      }
    ]
  }
}
