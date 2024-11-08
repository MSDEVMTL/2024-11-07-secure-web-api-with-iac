param location string = resourceGroup().location

// Parameters for database.bicep
param sqlServerName string = uniqueString('sqlserver', resourceGroup().id)
param sqlDBName string = 'SampleDB'
param administratorLogin string
@secure()
param administratorLoginPassword string

// Parameters for app.bicep
param webAppName string = uniqueString(resourceGroup().id)
param webAppSku string = 'Basic'
param webAppSkuCode string = 'B1'

// Parameters for keyvault.bicep
param keyVaultName string
param enabledForDeployment bool = false
param enabledForDiskEncryption bool = false
param enabledForTemplateDeployment bool = true
param tenantId string = subscription().tenantId
param objectId1 string
param keysPermissions array = [
  'all'
]
param secretsPermissions array = [
  'all'
]
@allowed([
  'standard'
  'premium'
])
param keyVaultSkuName string = 'standard'

// Module for database.bicep
module database 'database.bicep' = {
  name: 'databaseDeployment'
  params: {
    sqlServerName: sqlServerName
    sqlDBName: sqlDBName
    location: location
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
  dependsOn: [
    keyvault
  ]
}

// Module for app.bicep
module app 'app.bicep' = {
  name: 'appDeployment'
  params: {
    webAppName: webAppName
    sku: webAppSku
    skuCode: webAppSkuCode
    location: location
  }
  dependsOn: [
    keyvault
    database
  ]
}

// Module for keyvault.bicep
module keyvault 'keyvault.bicep' = {
  name: 'keyvaultDeployment'
  params: {
    keyVaultName: keyVaultName
    location: location
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    tenantId: tenantId
    objectId1: objectId1
    keysPermissions: keysPermissions
    secretsPermissions: secretsPermissions
    skuName: keyVaultSkuName
  }
}
