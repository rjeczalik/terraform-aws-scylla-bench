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
	template = "${file(format("%s/scripts/install-deps.sh", path.module))}"

	vars = {
		public_keys = "${join("\n", data.template_file.public_keys.*.rendered)}"
	}
}

data "template_file" "create_schema" {
	template = "${var.create_schema_script == "" ? "echo done" : var.create_schema_script == "default" ? file(format("%s/scripts/create-schema.sh", path.module)) : var.create_schema_script}"

	vars = {
		schema = "${var.schema}"
		username = "${var.username}"
		password = "${var.password}"
		first_seed = "${element(var.seeds, 0)}"
		seeds = "${join(",", var.seeds)}"
	}

	count = "${var.instances}"
}

data "template_file" "write" {
	template = "${var.write_script == "" ? "echo done" : var.write_script == "default" ? file(format("%s/scripts/write.sh", path.module)) : var.write_script}"

	vars = {
		schema = "${var.schema}"
		count = "${var.keys / var.instances}"
		limit = "${var.limit}"
		username = "${var.username}"
		password = "${var.password}"
		first_seed = "${element(var.seeds, 0)}"
		seeds = "${join(",", var.seeds)}"
		range_from = "${(var.keys / var.instances) * count.index + var.offset}"
		range_to = "${(var.keys / var.instances) * (count.index + 1) + var.offset}"
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

