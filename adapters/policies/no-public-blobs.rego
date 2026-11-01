package sample.no_public_blobs

deny contains violation if {
	some resource in input.resource_changes
	resource.type == "Microsoft.Storage/storageAccounts"
	resource.change.after.properties.allowBlobPublicAccess == true
	violation := {
		"msg": "storage accounts refuse public blob access",
		"address": resource.address,
	}
}
