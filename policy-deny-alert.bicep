// alerts/policy-deny-alert.bicep

@description('Resource ID of the Log Analytics workspace used as alert scope.')
param workspaceId string

@description('Resource ID of the Action Group that receives the alert.')
param actionGroupId string

// Use a supported API version for Metric Alerts
resource policyDenyAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'Policy-Deny-Activity-Detection'
  location: 'global'
  properties: {
    description: 'Alert when policy-based DENY actions occur'
    severity: 2          // 0 = Critical, 1 = Error, 2 = Warning, 3 = Informational, 4 = Verbose
    enabled: true
    autoMitigate: true

    // Scope: the resource IDs this alert watches (your Log Analytics workspace)
    scopes: [
      workspaceId
    ]

    // How often to evaluate + over what time window
    evaluationFrequency: 'PT5M'
    windowSize: 'PT10M'

    // Metric criteria. For 2018-03-01, you must specify odata.type and criterionType
    criteria: {
      odata.type: 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'PolicyDenyActivityCriteria'
          metricNamespace: 'AzureActivity'
          metricName: 'PolicyDenyCount'
          timeAggregation: 'Count'
          operator: 'GreaterThan'
          threshold: 0
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }

    // Actions: array of action groups for metricAlerts 2018-03-01
    actions: [
      {
        actionGroupId: actionGroupId
        webHookProperties: {}
      }
    ]
  }
}
