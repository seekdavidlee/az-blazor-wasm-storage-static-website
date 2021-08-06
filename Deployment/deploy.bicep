param location string = resourceGroup().location
param environment string
param branch string
param managedUserId string
param suffix string
param scriptVersion string = utcNow()

var demoName = '${suffix}demo'
var tags = {
  'stack-name': demoName
  'environment': environment
  'branch': branch
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: demoName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
  tags: tags
}

resource cdn 'Microsoft.Cdn/profiles@2020-09-01' = {
  name: demoName
  location: location
  tags: tags
  sku: {
    name: 'Standard_Microsoft'
  }
}

resource staticWebsiteSetup 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: demoName
  kind: 'AzurePowerShell'
  location: location
  tags: tags
  dependsOn: [
    storageAccount
  ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${managedUserId}': {}
    }
  }
  properties: {
    forceUpdateTag: scriptVersion
    azPowerShellVersion: '5.0'
    retentionInterval: 'P1D'
    arguments: '-StorageAccountName ${storageAccount.name} -ResourceGroupName ${resourceGroup().name}'
    scriptContent: loadTextContent('deploywebsite.ps1')
  }
}

var edgeUrl = 'https://${demoName}.azureedge.net'

var websiteUrl = replace(replace(staticWebsiteSetup.properties.outputs.endpoint, 'https://', ''), '/', '')
resource cdnEndpoint 'Microsoft.Cdn/profiles/endpoints@2020-09-01' = {
  name: demoName
  parent: cdn
  location: 'global'
  tags: tags
  dependsOn: [
    staticWebsiteSetup
  ]
  properties: {
    originHostHeader: websiteUrl
    isCompressionEnabled: true
    isHttpAllowed: false
    isHttpsAllowed: true
    contentTypesToCompress: [
      'application/eot'
      'application/font'
      'application/font-sfnt'
      'application/javascript'
      'application/json'
      'application/opentype'
      'application/otf'
      'application/pkcs7-mime'
      'application/truetype'
      'application/ttf'
      'application/vnd.ms-fontobject'
      'application/xhtml+xml'
      'application/xml'
      'application/xml+rss'
      'application/x-font-opentype'
      'application/x-font-truetype'
      'application/x-font-ttf'
      'application/x-httpd-cgi'
      'application/x-javascript'
      'application/x-mpegurl'
      'application/x-opentype'
      'application/x-otf'
      'application/x-perl'
      'application/x-ttf'
      'font/eot'
      'font/ttf'
      'font/otf'
      'font/opentype'
      'image/svg+xml'
      'text/css'
      'text/csv'
      'text/html'
      'text/javascript'
      'text/js'
      'text/plain'
      'text/richtext'
      'text/tab-separated-values'
      'text/xml'
      'text/x-script'
      'text/x-component'
      'text/x-java-source'
    ]
    origins: [
      {
        name: replace(websiteUrl, '.', '-')
        properties: {
          hostName: websiteUrl
          httpPort: 80
          httpsPort: 443
          originHostHeader: websiteUrl
          priority: 1
          weight: 1000
          enabled: true
        }
      }
    ]
  }
}

resource storageAccountBlobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  parent: storageAccount
  name: 'default'
  dependsOn: [
    staticWebsiteSetup
  ]
  properties: {
    cors: {
      corsRules: [
        {
          allowedOrigins: [
            staticWebsiteSetup.properties.outputs.endpoint
          ]
          allowedMethods: [
            'POST'
            'GET'
            'OPTIONS'
            'HEAD'
            'PUT'
            'MERGE'
            'DELETE'
          ]
          maxAgeInSeconds: 120
          exposedHeaders: [
            '*'
          ]
          allowedHeaders: [
            '*'
          ]
        }
        {
          allowedOrigins: [
            edgeUrl
          ]
          allowedMethods: [
            'POST'
            'GET'
            'OPTIONS'
            'HEAD'
            'PUT'
            'MERGE'
            'DELETE'
          ]
          maxAgeInSeconds: 120
          exposedHeaders: [
            '*'
          ]
          allowedHeaders: [
            '*'
          ]
        }
      ]
    }
  }
}

output accountName string = storageAccount.name
