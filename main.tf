# Chef Supermarket AWS security group - https://docs.chef.io/supermarket.html
resource "aws_security_group" "chef-supermarket" {
  name        = "${var.hostname}.${var.domain} security group"
  description = "Supermarket server ${var.hostname}.${var.domain}"
  vpc_id      = "${var.aws_vpc_id}"
  tags        = {
    Name      = "${var.hostname}.${var.domain} security group"
  }
}
# SSH - allowed_cidrs
resource "aws_security_group_rule" "chef-supermarket_allow_22_tcp_all" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${split(",", var.allowed_cidrs)}"]
  security_group_id = "${aws_security_group.chef-supermarket.id}"
}
# HTTP (nginx)
resource "aws_security_group_rule" "chef-supermarket_allow_80_tcp_all" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-supermarket.id}"
}
# HTTPS (nginx)
resource "aws_security_group_rule" "chef-supermarket_allow_443_tcp_all" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-supermarket.id}"
}
# Egress: ALL
resource "aws_security_group_rule" "chef-supermarket_allow_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-supermarket.id}"
}
# Hack chef-server's attributes to support a private supermarket
resource "template_file" "attributes-json" {
  template = "${file("${path.module}/files/attributes-json.tpl")}"
  vars {
    cert      = "/var/opt/supermarket/ssl/${var.hostname}.${var.domain}.crt"
    chef_fqdn = "https://${var.chef_fqdn}"
    domain    = "${var.domain}"
    host      = "${var.hostname}"
    cert_key  = "/var/opt/supermarket/ssl/${var.hostname}.${var.domain}.key"
    oauth_id  = "text1"
    oauth_sec = "text2"
  }
}
resource "null_resource" "oc_id-supermarket" {
  depends_on = ["template_file.attributes-json"]
  connection {
    user        = "${lookup(var.ami_usermap, var.ami_os)}"
    private_key = "${var.aws_private_key_file}"
    host        = "${var.chef_fqdn}"
  }
  # Generate new attributes file with supermarket oc_id subscription
  provisioner "local-exec" {
    command = <<-EOC
      rm -rf .supermarket ; mkdir -p .supermarket
      bash ${path.module}/files/chef_api_request GET "/nodes/${var.chef_fqdn}" | jq '.normal' > .supermarket/attributes.json.orig
      grep -q 'applications' .supermarket/attributes.json.orig
      [ $? -ne 0 ] && rm -f .supermarket/attributes.json.orig && echo "Taking a 30s nap" && sleep 30 && bash ${path.module}/files/chef_api_request GET "/nodes/${var.chef_fqdn}" | jq '.normal' > .supermarket/attributes.json.orig
      grep -q 'applications' .supermarket/attributes.json.orig
      result=$?
      [ $result -eq 0 ] && sed "s/\(applications.*\\\n  }\)\\\n/\1,\\\n  'supermarket' => {\\\n    'redirect_uri' => 'https:\/\/${var.hostname}.${var.domain}\/auth\/chef_oauth2\/callback\/'\\\n  }\\\n/"  .supermarket/attributes.json.orig > .supermarket/attributes.json
      [ $result -ne 0 ] && sed "s/\(configuration.*\)\",/\1\\\noc_id['applications'] = {\\\n  'supermarket' => {\\\n    'redirect_uri' => 'https:\/\/${var.hostname}.${var.domain}\/auth\/chef_oauth2\/callback'\\\n  }\\\n}\\\n\",/" .supermarket/attributes.json.orig > .supermarket/attributes.json
      echo "Modified Chef server attributes"
      EOC
  }
  # Upload new attributes file
  provisioner "file" {
    source      = ".supermarket/attributes.json"
    destination = "supermarket-attributes.json"
  }
  # Execute new Chef run if no supermarket.json exists
  provisioner "remote-exec" {
    inline = [
      "rm -rf .supermarket ; mkdir -p .supermarket",
      "[ -f /etc/opscode/oc-id-applications/supermarket.json ] && echo ABORT ABORT ABORT ABORT",
      "[ -f /etc/opscode/oc-id-applications/supermarket.json ] && exit 1",
      "sudo chef-client -j supermarket-attributes.json",
      "rm -f supermarket-attributes.json",
      "sudo cp /etc/opscode/oc-id-applications/supermarket.json .supermarket/supermarket.json",
      "sudo chown ${lookup(var.ami_usermap, var.ami_os)} .supermarket/supermarket.json",
    ]
  }
  # Copy back configuration
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no ${lookup(var.ami_usermap, var.ami_os)}@${var.chef_fqdn}:.supermarket/supermarket.json .supermarket/supermarket.json"
  }
  # Push in some cookbooks
  provisioner "remote-exec" {
    script = "${path.module}/files/chef-cookbooks.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo knife cookbook upload -a -c ${var.knife_rb} --force --cookbook-path /var/chef/cookbooks",
      "sudo rm -rf /var/chef/cookbooks",
    ]
  }
  # Capture the app id and secret from the downloaded supermarket.json
  provisioner "local-exec" {
    command = "cat .supermarket/supermarket.json|grep uid|grep -Eo '[a-f0-9]{32,}' | tr -d '\n' > .supermarket/chef_oauth2_app_id"
  }
  provisioner "local-exec" {
    command = "cat .supermarket/supermarket.json|grep secret|grep -Eo '[a-f0-9]{32,}' | tr -d '\n' > .supermarket/chef_oauth2_secret"
  }
  # Use Perl magic to slip in the app id and secret
  provisioner "local-exec" {
    command = <<-EOC
      cat > .supermarket/${var.hostname}.${var.domain}-attributes.json <<EOF
      ${template_file.attributes-json.rendered}
      EOF
      cd .supermarket && perl -pe 's/text1/`cat chef_oauth2_app_id`/ge' -i ${var.hostname}.${var.domain}-attributes.json && cd ..
      cd .supermarket && perl -pe 's/text2/`cat chef_oauth2_secret`/ge' -i ${var.hostname}.${var.domain}-attributes.json && cd ..
      EOC
  }
}
module "ocid-attributes" {
  source     = "ocid-attributes"
  attributes = ".supermarket/${var.hostname}.${var.domain}-attributes.json"
}
#
# Wait on
#
resource "null_resource" "wait_on" {
  provisioner "local-exec" {
    command = "echo Waited on ${var.wait_on} before proceeding"
  }
}
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}
#
# Provision server
#
resource "aws_instance" "chef-supermarket" {
  depends_on    = ["null_resource.oc_id-supermarket","null_resource.wait_on"]
  ami           = "${lookup(var.ami_map, format("%s-%s", var.ami_os, var.aws_region))}"
  count         = "${var.server_count}"
  instance_type = "${var.aws_flavor}"
  associate_public_ip_address = "${var.public_ip}"
  subnet_id     = "${var.aws_subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.chef-supermarket.id}"]
  key_name      = "${var.aws_key_name}"
  tags = {
    Name        = "${var.hostname}.${var.domain}"
    Description = "${var.tag_description}"
  }
  root_block_device = {
    delete_on_termination = "${var.root_delete_termination}"
  }
  connection {
    user        = "${lookup(var.ami_usermap, var.ami_os)}"
    private_key = "${var.aws_private_key_file}"
    host        = "${self.public_ip}"
  }
  provisioner "local-exec" {
    command = "knife node-delete   ${var.hostname}.${var.domain} -y -c ${var.knife_rb} ; echo OK"
  }
  provisioner "local-exec" {
    command = "knife client-delete ${var.hostname}.${var.domain} -y -c ${var.knife_rb} ; echo OK"
  }
  # Handle iptables
  provisioner "remote-exec" {
    inline = [
      "sudo service iptables stop",
      "sudo chkconfig iptables off",
      "sudo ufw disable",
      "echo Say WHAT one more time"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir -p .supermarket",
      "sudo mkdir -p /var/opt/supermarket/ssl",
    ]
  }
  provisioner "file" {
    source      = "${var.ssl_cert}"
    destination = ".supermarket/${var.hostname}.${var.domain}.crt"
  }
  provisioner "file" {
    source      = "${var.ssl_key}"
    destination = ".supermarket/${var.hostname}.${var.domain}.key"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv .supermarket/${var.hostname}.${var.domain}.* /var/opt/supermarket/ssl",
      "sudo chown -R root:root /var/opt/supermarket/ssl",
    ]
  }
  # Provision with Chef
  provisioner "chef" {
    attributes_json = "${file("${module.ocid-attributes.attributes}")}"
    environment     = "_default"
    log_to_file     = "${var.log_to_file}"
    node_name       = "${aws_instance.chef-supermarket.tags.Name}"
    run_list        = ["recipe[system::default]","recipe[chef-client::default]","recipe[chef-client::config]","recipe[chef-client::delete_validation]","recipe[supermarket-omnibus-cookbook::default]"]
    server_url      = "https://${var.chef_fqdn}/organizations/${var.chef_org}"
    validation_client_name = "${var.chef_org}-validator"
    validation_key  = "${file("${var.chef_org_validator}")}"
    version         = "${var.client_version}"
  }
}

