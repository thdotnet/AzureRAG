// Parameters
param location string
param storageAccountName string
param containerName string
param searchServiceName string
param openAIServiceName string

// Managed Identity
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-01-01' = {
  name: 'myUserAssignedIdentity'
  location: location
}

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

// Blob Service
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  name: 'default'
  parent: storageAccount
}

// Blob Container
resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: containerName
  parent: blobService
  properties: {
    publicAccess: 'None'
  }
}

// Azure AI Search Service
resource searchService 'Microsoft.Search/searchServices@2020-08-01' = {
  name: searchServiceName
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    partitionCount: 1
    replicaCount: 1
  }
}

// Azure OpenAI Service
resource openAIService 'Microsoft.CognitiveServices/accounts@2017-04-18' = {
  name: openAIServiceName
  location: location
  kind: 'OpenAI'
  sku: {
    name: 'S0'
    tier: 'Standard'
  }
  properties: {
    apiProperties: {}
  }
}

// Output the OpenAI endpoint
output openAIEndpoint string = openAIService.properties.endpoint

// Data Source for Azure AI Search
resource dataSource 'Microsoft.Search/searchServices/dataSources@2020-08-01' = {
  name: 'myDataSource'
  parent: searchService
  properties: {
    type: 'azureblob'
    credentials: {
      connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=core.windows.net'
    }
    container: {
      name: containerName
    }
    identity: {
      type: 'UserAssigned'
      userAssignedIdentity: userAssignedIdentity.id
    }
  }
}

// Index for Azure AI Search
resource index 'Microsoft.Search/searchServices/indexes@2020-08-01' = {
  name: 'myIndex'
  parent: searchService
  properties: {
    fields: [
      {
        name: 'id'
        type: 'Edm.String'
        key: true
      }
      {
        name: 'content'
        type: 'Edm.String'
      }
    ]
  }
}

// Indexer for Azure AI Search
resource indexer 'Microsoft.Search/searchServices/indexers@2020-08-01' = {
  name: 'myIndexer'
  parent: searchService
  properties: {
    dataSourceName: dataSource.name
    targetIndexName: index.name
    schedule: {
      interval: 'PT1H'
    }
  }
}

// Role Assignments
resource roleAssignmentStorageAccount 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, storageAccount.id, 'Storage Blob Data Reader')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    principalId: userAssignedIdentity.properties.principalId
    scope: storageAccount.id
  }
}

resource roleAssignmentSearchService 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, searchService.id, 'Search Service Contributor')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ae349356-3a1b-4a5e-921d-19cd256dfac6')
    principalId: userAssignedIdentity.properties.principalId
    scope: searchService.id
  }
}
