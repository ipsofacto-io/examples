resource account 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'ipsosamplepublic'
  location: 'westeurope'
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    allowBlobPublicAccess: true
  }
}
