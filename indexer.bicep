param location string
param searchServiceName string
param storageConnectionString string
param containerName string = 'mycontainer'

// Data Source for Azure AI Search
resource dataSource 'Microsoft.Search/searchServices/dataSources@2020-08-01' = {
  name: 'myDataSource'
  parent: {
    name: searchServiceName
    type: 'Microsoft.Search/searchServices'
  }
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
  parent: {
    name: searchServiceName
    type: 'Microsoft.Search/searchServices'
  }
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
  parent: {
    name: searchServiceName
    type: 'Microsoft.Search/searchServices'
  }
  properties: {
    dataSourceName: dataSource.name
    targetIndexName: index.name
    schedule: {
      interval: 'PT1H'
    }
  }
}
