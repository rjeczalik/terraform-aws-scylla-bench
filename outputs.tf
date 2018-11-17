output "instance_ips" {
	description = ""
	value = "${aws_instance.scylla.*.public_ip}"
}

output "ssh_private_key" {
	description = ""
	value = "${tls_private_key.scylla.private_key_pem}"
}
