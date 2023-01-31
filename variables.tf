variable "aws_access_key" {
	description = "AWS Access Key ID"
	default = ""
}

variable "aws_secret_key" {
	description = "AWS Secret Access Key"
	default = ""
}

variable "aws_region" {
	description = "AWS Region"
	default = "us-east-1"
}

variable "aws_instance_type" {
	description = "AWS Instance Type"
	default = "c4.large"
}

variable "aws_vpc_id" {
	description = "AWS VPC to use"
	default = ""
}

variable "aws_tags" {
	description = "Tags for each created AWS resource"
	type = map(string)
	default = {
		"environment" = "scylla-bench"
		"version" = "0.1.0"
		"keep" = "alive"
	}
}

variable "seeds" {
	description = "Network addresses of Scylla nodes"
	type = list(string)
}

variable "username" {
	description = "Scylla CQL username"
}

variable "password" {
	description = "Scylla CQL password"
}

variable "schema" {
	description = "Scylla keyspace schema"
	default = "replication(factor=3)"
}

variable "instances" {
	description = "Number of scylla-bench instances (concurrency)"
	default = 4
}

variable "keys" {
	description = "Number of unique keys to split between instances"
	default = 1000000000
}

variable "offset" {
	description = "Starting number of unique keys"
	default = 0
}

variable "limit" {
	description = "Req/s limit per instance"
	default = 10000
}

variable "create_schema_script" {
	description = "Override command template for creating keyspace schema"
	default = "default"
}

variable "write_script" {
	description = "Override command template for writing data"
	default = "default"
}

variable "dry_run" {
	description = "Do not execute commands when set to true"
	default = false
}

variable "public_keys" {
	description = "Additional public keys to add to each instance"
	type = list(string)
	default = []
}

variable "allow_cidr" {
	description = "Additional CIDR blocks to add to a security group"
	type = list(string)
	default = []
}

variable "allow_ports" {
	description = "Additional prots to open within a security group"
	type = list(string)
	default = [22]
}
