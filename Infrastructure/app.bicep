param webAppName string = uniqueString(resourceGroup().id) // Generate unique String for web app name
param sku string = 'Basic' // The SKU of App Service Plan
param skuCode string = 'B1' // The SKU code of App Service Plan
param location string = resourceGroup().location // Location for all resources

var appServicePlanName = toLower('AppServicePlan-${webAppName}')
var webSiteName = toLower('${webAppName}')

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    tier: sku
    name: skuCode
  }
  kind: 'app'
  properties: {
    reserved: false
    zoneRedundant: false
  }
}

resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: webSiteName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnet'
        }
      ]
      netFrameworkVersion: 'v8.0'
      use32BitWorkerProcess: false
    }
    
  }
}
