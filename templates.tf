data "aws_availability_zones" "all" {}

data "aws_ami" "centos" {
	most_recent = true

	filter {
		name   = "name"
		values = ["CentOS Linux 7 x86_64 HVM EBS*"]
	}

	filter {
		name   = "architecture"
		values = ["x86_64"]
	}

	filter {
		name   = "root-device-type"
		values = ["ebs"]
	}

	owners = ["679593333241"]
}

data "external" "my_ip" {
	program = ["bash", "${path.module}/scripts/my-ip.sh"]
}

data "template_file" "install_deps" {
	template = <<EOF
#!/bin/bash

set -eu

sudo yum install -y epel-release wget screen
sudo wget -O /etc/yum.repos.d/scylla.repo http://repositories.scylladb.com/scylla/repo/2e2f1a5f-4195-4691-8e19-43f6af57b0e2/centos/scylladb-2018.1.repo
sudo yum install -y scylla-enterprise-tools

mkdir -p ~/.ssh
touch ~/.ssh/authorized_keys
chmod 0700 ~/.ssh
chmod 0600 ~/.ssh/authorized_keys

cat <<EOG | while read key; do echo "$key" >> ~/.ssh/authorized_keys; done
$${public_keys}
EOG

EOF

	vars = {
		public_keys = "${join("\n", data.template_file.public_keys.*.rendered)}"
	}
}

data "template_file" "cmd_create_schema" {
	template = "${var.cmd_create_schema}"

	vars = {
		schema = "${var.schema}"
		username = "${var.username}"
		password = "${var.password}"
		first_seed = "${element(var.seeds, 0)}"
		seeds = "${join(" ", var.seeds)}"
	}

	count = "${var.instances}"
}

data "template_file" "cmd_write" {
	template = "${var.cmd_write}"

	vars = {
		schema = "${var.schema}"
		count = "${var.keys / var.instances}"
		username = "${var.username}"
		password = "${var.password}"
		first_seed = "${element(var.seeds, 0)}"
		seeds = "${join(" ", var.seeds)}"
		range_from = "${(var.keys / var.instances) * count.index}"
		range_to = "${(var.keys / var.instances) * (count.index + 1)}"
	}

	count = "${var.instances}"
}

data "template_file" "public_keys" {
	template = "$${public_key}"

	vars = {
		public_key = "${file(element(var.public_keys, count.index))}"
	}

	count = "${length(var.public_keys)}"
}
