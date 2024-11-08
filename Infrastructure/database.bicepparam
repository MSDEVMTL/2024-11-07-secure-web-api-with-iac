using 'database.bicep'

param administratorLogin = '#{administratorLogin}#'
param administratorLoginPassword = az.getSecret('#{subscriptionId}#','#{resourceGroupName}#','#{keyvaultName}#','#{dboPasswordSecretName}#')
param sqlServerName = '#{sqlServerName}#'
param sqlDBName = '#{sqlDBName}#'
