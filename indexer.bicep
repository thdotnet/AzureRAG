param location string
param searchServiceName string
param storageConnectionString string
param containerName string = 'mycontainer'

// Azure AI Search Service (existing)
resource searchService 'Microsoft.Search/searchServices@2020-08-01' existing = {
  name: searchServiceName
  location: location
}

// Data Source for Azure AI Search
resource dataSource 'Microsoft.Search/searchServices/dataSources@2020-08-01' = {
  name: 'myDataSource'
  parent: searchService
  properties: {
    type: 'azureblob'
    credentials: {
      connectionString: storageConnectionString
    }
    container: {
      name: containerName
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
