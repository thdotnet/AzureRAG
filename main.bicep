param location = 'eastus'
param storageAccountName string
param searchServiceName string
param openAIServiceName string

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

// Indexer (connects Azure AI Search to the Storage Account)
resource dataSource 'Microsoft.Search/searchServices/dataSources@2020-08-01' = {
  name: 'myDataSource'
  parent: searchService
  properties: {
    type: 'azureblob'
    credentials: {
      connectionString: storageAccount.properties.primaryEndpoints.blob
    }
    container: {
      name: 'files'
    }
  }
}

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
