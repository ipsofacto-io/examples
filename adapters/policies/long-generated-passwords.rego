package sample.long_generated_passwords

deny contains violation if {
	some resource in input.resource_changes
	resource.type == "random:index/randomPassword:RandomPassword"
	resource.change.after.length < 16
	violation := {
		"msg": "generated passwords have at least 16 characters",
		"address": resource.address,
	}
}
