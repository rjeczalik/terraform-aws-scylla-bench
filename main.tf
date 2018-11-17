provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region = "${var.aws_region}"
}

resource "aws_instance" "scylla" {
	ami = "${data.aws_ami.centos.id}"
	instance_type = "${var.aws_instance_type}"
	key_name = "${aws_key_pair.scylla.key_name}"
	availability_zone = "${element(data.aws_availability_zones.all.names, 0)}"
	subnet_id = "${element(aws_subnet.scylla.*.id, count.index)}"

	security_groups = ["${aws_security_group.scylla.id}"]

	credit_specification {
		cpu_credits = "unlimited"
	}

	tags = "${var.aws_tags}"

	count = "${var.instances}"
}

resource "null_resource" "install_deps" {
	triggers {
		ids = "${join(",", aws_instance.scylla.*.id)}"
	}

	connection {
		type = "ssh"
		host = "${element(aws_instance.scylla.*.public_ip, count.index)}"
		user = "centos"
		private_key = "${tls_private_key.scylla.private_key_pem}"
		timeout = "1m"
	}

	provisioner "file" {
		destination = "install-deps.sh"
		content = "${data.template_file.install_deps.rendered}"
	}

	provisioner "file" {
		destination = "create-schema.sh"
		content = "${element(data.template_file.create_schema.*.rendered, count.index)}"
	}

	provisioner "file" {
		destination = "write.sh"
		content = "${element(data.template_file.write.*.rendered, count.index)}"
	}

	provisioner "remote-exec" {
		inline = [
			"chmod +x install-deps.sh create-schema.sh write.sh",
			"./install-deps.sh"
		]
	}

	count = "${var.instances}"
	depends_on = ["aws_instance.scylla"]
}

resource "null_resource" "create_schema" {
	triggers {
		ids = "${join(",", var.seeds)}"
	}

	connection {
		type = "ssh"
		host = "${element(aws_instance.scylla.*.public_ip, 0)}"
		user = "centos"
		private_key = "${tls_private_key.scylla.private_key_pem}"
		timeout = "1m"
	}

	provisioner "remote-exec" {
		inline = ["./create-schema.sh"]
	}

	count = "${var.dry_run ? 0 : 1}"
	depends_on = ["null_resource.install_deps"]
}

resource "null_resource" "write" {
	triggers {
		ids = "${join(",", var.seeds)}"
	}

	connection {
		type = "ssh"
		host = "${element(aws_instance.scylla.*.public_ip, count.index)}"
		user = "centos"
		private_key = "${tls_private_key.scylla.private_key_pem}"
		timeout = "1m"
	}

	provisioner "remote-exec" {
		inline = [
			"screen -S scylla-bench -d -m",
			"screen -r scylla-bench -X stuff $'date | tee start_date\n'",
			"screen -r scylla-bench -X stuff $'./write.sh | tee scylla-bench.log\n'",
			"screen -r scylla-bench -X stuff $'date | tee end_date\n'",
		]
	}

	depends_on = ["null_resource.create_schema"]
	count = "${var.dry_run ? 0 : var.instances}"
}

resource "tls_private_key" "scylla" {
	algorithm = "RSA"
	rsa_bits = "2048"
}

resource "aws_key_pair" "scylla" {
	key_name = "scylla-bench"
	public_key = "${tls_private_key.scylla.public_key_openssh}"
}

resource "aws_vpc" "scylla" {
	cidr_block = "10.0.0.0/16"

	tags = "${var.aws_tags}"
}

resource "aws_internet_gateway" "scylla" {
	vpc_id = "${aws_vpc.scylla.id}"

	tags = "${var.aws_tags}"
}

resource "aws_subnet" "scylla" {
	availability_zone = "${element(data.aws_availability_zones.all.names, 0)}"
	cidr_block = "10.0.1.0/24"
	vpc_id = "${aws_vpc.scylla.id}"
	map_public_ip_on_launch = true

	tags = "${var.aws_tags}"

	depends_on = ["aws_internet_gateway.scylla"]
}

resource "aws_route_table" "scylla" {
	vpc_id = "${aws_vpc.scylla.id}"

	route = {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.scylla.id}"
	}

	tags = "${var.aws_tags}"
}

resource "aws_route_table_association" "public" {
	route_table_id = "${aws_route_table.scylla.id}"
	subnet_id = "${aws_subnet.scylla.id}"
}

resource "aws_security_group" "scylla" {
	name = "scylla-bench"
	vpc_id = "${aws_vpc.scylla.id}"

	tags = "${var.aws_tags}"
}

resource "aws_security_group_rule" "scylla_egress" {
	type = "egress"
	security_group_id = "${aws_security_group.scylla.id}"
	cidr_blocks = ["0.0.0.0/0"]
	from_port = "0"
	to_port = "0"
	protocol = "-1"
}

resource "aws_security_group_rule" "scylla_ingress" {
	type = "ingress"
	security_group_id = "${aws_security_group.scylla.id}"
	cidr_blocks = ["${compact(concat(list(format("%s/32", data.external.my_ip.result.public_ip)), var.allow_cidr))}"]
	from_port = "${element(var.allow_ports, count.index)}"
	to_port = "${element(var.allow_ports, count.index)}"
	protocol = "tcp"

	count = "${length(var.allow_ports)}"
}
