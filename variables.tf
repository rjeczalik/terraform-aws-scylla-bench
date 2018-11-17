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

variable "cmd_create_schema" {
	description = ""
	default = <<EOF
cassandra-stress write n=1 cl=ALL -schema "$${schema}" -mode native cql3 user="$${username}" password="$${password}" -seed "$${first_seed}"
EOF
}

variable "cmd_write" {
	description = ""
	default = <<EOF
cassandra-stress write cl=QUORUM n=$${count} -mode native cql3 user="$${username}" password="$${password}" -rate threads=350 limit='20000/s' -seed "$${first_seed}" -pop seq=$${range_from}..$${range_to}
EOF
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
