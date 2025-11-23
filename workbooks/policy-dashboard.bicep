// workbooks/policy-dashboard.bicep
targetScope = 'resourceGroup'

@description('Workbook display title')
param workbookDisplayName string = 'Cloud Policy Compliance Dashboard'

@description('Workbook content in JSON form.')
param workbookJson string

@description('Location for deployment.')
param location string = resourceGroup().location

@description('Unique workbook resource name (must match JSON id).')
param workbookName string

resource workbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: workbookName
  location: location
  kind: 'shared'
  tags: {
    'hidden-title': workbookDisplayName
  }
  properties: {
    displayName: workbookDisplayName
    serializedData: workbookJson
    version: '1.0'
    category: 'workbook'
    sourceId: subscription().id
  }
}
