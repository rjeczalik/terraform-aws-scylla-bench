variable "aws_access_key" {
	description = ""
}

variable "aws_secret_key" {
	description = ""
}

variable "aws_region" {
	description = ""
	default = "us-east-1"
}

variable "aws_instance_type" {
	description = ""
	default = "c4.large"
}

variable "aws_tags" {
	description = ""
	type = "map"
	default = {
		"environment" = "scylla-bench"
		"version" = "0.1.0"
		"keep" = "alive"
	}
}

variable "seeds" {
	description = ""
	type = "list"
}

variable "username" {
	description = ""
	default = "cassandra"
}

variable "password" {
	description = ""
	default = "cassandra"
}

variable "schema" {
	description = ""
	default = "replication(factor=3)"
}

variable "instances" {
	description = ""
	default = 4
}

variable "keys" {
	description = ""
	default = 1000000000
}

variable "offset" {
	description = ""
	default = 0
}

variable "limit" {
	description = ""
	default = 10000
}

variable "create_schema_script" {
	description = ""
	default = "default"
}

variable "write_script" {
	description = ""
	default = "default"
}

variable "dry_run" {
	description = ""
	default = false
}

variable "public_keys" {
	description = ""
	type = "list"
	default = []
}

variable "allow_cidr" {
	description = ""
	type = "list"
	default = []
}

variable "allow_ports" {
	description = ""
	type = "list"
	default = [22]
}
