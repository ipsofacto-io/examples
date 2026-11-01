package sample.endpoint_owner

deny contains violation if {
	some resource in input.resource_changes
	resource.type == "terraform_data"
	# A resource being destroyed has no after, and it needs no owner.
	is_object(resource.change.after)
	not resource.change.after.input.owner
	violation := {
		"msg": "service endpoints name an owning team",
		"address": resource.address,
	}
}
