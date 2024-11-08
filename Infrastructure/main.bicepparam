using 'main.bicep'

param keyVaultName = '#{keyvaultName}#'
param objectId1 = '#{azureDevOpsAppId}#'

param administratorLogin = '#{administratorLogin}#'
param administratorLoginPassword = az.getSecret('#{subscriptionId}#','#{resourceGroupName}#','#{keyvaultName}#','#{dboPasswordSecretName}#')
param sqlServerName = '#{sqlServerName}#'
param sqlDBName = '#{sqlDBName}#'

param webAppSku = '#{sku}#'
param webAppSkuCode = '#{skuCode}#'
param webAppName = '#{webApiName}#'

