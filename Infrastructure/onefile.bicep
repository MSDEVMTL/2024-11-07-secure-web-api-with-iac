param webAppName string = uniqueString(resourceGroup().id) // Generate unique String for web app name
param sku string = 'Basic' // The SKU of App Service Plan
param skuCode string = 'B1' // The SKU code of App Service Plan
param location string = resourceGroup().location // Location for all resources

param sqlServerName string = uniqueString('sql', resourceGroup().id)
param sqlDBName string = 'SampleDB'
param administratorLogin string
@secure()
param administratorLoginPassword string

param keyVaultName string
param enabledForDeployment bool = false
param enabledForDiskEncryption bool = false
param enabledForTemplateDeployment bool = true
param tenantId string = subscription().tenantId
param iacDeploymentPrincipalId string
@allowed(['standard', 'premium'])
param skuName string = 'standard'

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
  identity: {
    type: 'SystemAssigned'
  }
}

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: sqlDBName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

resource SQLAllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2020-11-01-preview' = {
  name: 'AllowAllWindowsAzureIps'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource kv 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enableRbacAuthorization: true
    tenantId: tenantId
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    sku: {
      name: skuName
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource kvSecretAdminLogin 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: 'sqlAdminLogin'
  parent: kv
  properties: {
    value: administratorLogin
  }
}

resource kvSecretAdminPassword 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: 'sqlAdminPassword'
  parent: kv
  properties: {
    value: administratorLoginPassword
  }
}

resource appServiceKeyVaultSecretRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(webSiteName, 'KeyVaultSecretUser')
  scope: kv
  properties: {
    // Key Vault Secrets User
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
    principalId: appService.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource iacDeploymentPrincipalRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('IACDeploymentPrincipal', 'KeyVaultSecretUser')
  scope: kv
  properties: {
    // Key Vault Secrets Officer
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7')
    principalId: iacDeploymentPrincipalId
    principalType: 'User' // could be 'User', 'ServicePrincipal', 'Group'
  }
}

resource appServiceSettings 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: appService
  name: 'appsettings'
  properties: {
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=yourstorageaccount;AccountKey=youraccountkey;EndpointSuffix=${environment().suffixes.storage}'
    SQL_ADMIN_LOGIN: '@Microsoft.KeyVault(SecretUri=${kvSecretAdminLogin.properties.secretUriWithVersion}'
    SQL_ADMIN_PASSWORD: '@Microsoft.KeyVault(SecretUri=${kvSecretAdminPassword.properties.secretUriWithVersion}'
  }
}

resource appServiceConnectionStrings 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: appService
  name: 'connectionstrings'
  properties: {

    SQL_CONNECTION_STRING: {
      type: 'SQLAzure'
      value: 'Server=tcp:${sqlServerName}.${environment().suffixes.sqlServerHostname},1433;Database=${sqlDBName};User ID=${administratorLogin}@${sqlServerName};Password=${administratorLoginPassword}};Encrypt=true;Connection Timeout=30;'
    }
  }
}
