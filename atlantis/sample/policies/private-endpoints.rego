package sample.private_endpoints

deny contains violation if {
	some resource in input.resource_changes
	resource.type == "terraform_data"
	resource.change.after.input.public == true
	violation := {
		"msg": "service endpoints stay private",
		"address": resource.address,
	}
}
