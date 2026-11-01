package sample.endpoint_owner

deny contains violation if {
	some resource in input.resource_changes
	resource.type == "terraform_data"
	not resource.change.after.input.owner
	violation := {
		"msg": "service endpoints name an owning team",
		"address": resource.address,
	}
}
