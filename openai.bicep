param location string = 'eastus'
param openAIServiceName string

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
