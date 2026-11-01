package sample.no_public_buckets

deny contains violation if {
	some resource in input.resource_changes
	resource.type == "AWS::S3::Bucket"
	resource.change.after.AccessControl in {"PublicRead", "PublicReadWrite"}
	violation := {
		"msg": "S3 buckets have no public ACL",
		"address": resource.address,
	}
}
