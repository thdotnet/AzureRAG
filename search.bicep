param location string = 'eastus'
param searchServiceName string

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
