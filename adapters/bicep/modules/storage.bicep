resource account 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'ipsosampleprivate'
  location: 'westeurope'
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    allowBlobPublicAccess: false
  }
}
