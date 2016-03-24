# Outputs
output "fqdn" {
  value = "${aws_instance.chef-supermarket.tags.Name}"
}
output "private_ip" {
  value = "${aws_instance.chef-supermarket.private_ip}"
}
output "public_ip" {
  value = "${aws_instance.chef-supermarket.public_ip}"
}

