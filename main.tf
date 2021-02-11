data "template_file" "openvpn_init" {
  template = file("${path.module}/templates/openvpn_init.tpl")

  vars = {
    admin_user      = var.admin_user
    admin_password  = var.admin_password
    local_auth      = var.local_auth
    reroute_dns     = var.reroute_dns
    reroute_gw      = var.reroute_gw
    public_hostname = aws_eip.openvpn_eip.public_ip
  }
}

# The OpenVPN Access Server license can only be activated once.  If the instance is destroyed, a new
# license key needs to be obtained by contacting OpenVPN support.
# https://docs.openvpn.net/getting-started/amazon-web-services-ec2-byol-appliance-quick-start-guide/
#
# Because we need the sandbox instance to be easily destroyed
# and [lifetimes don't support interpolation](https://github.com/hashicorp/terraform/issues/3116)
# we use a duplicate resource and set one of them to "zero instances" in order to manage the lifecycle.

locals {
  ami_id             = var.ami_id
  instance_type      = "t2.micro"
  key_name           = var.key_name
  subnet_id          = var.public_subnet_id
  security_group_ids = [aws_security_group.openvpn.id]
  user_data          = data.template_file.openvpn_init.rendered
  name               = "OpenVPN"
  workspace          = terraform.workspace
}

resource "aws_instance" "openvpn_instance" {
  ami           = local.ami_id
  instance_type = local.instance_type
  key_name      = local.key_name
  subnet_id     = local.subnet_id
  vpc_security_group_ids = local.security_group_ids

  lifecycle {
    ignore_changes = [
      key_name,
      user_data,
      ami,
    ]
    prevent_destroy = true
  }

  user_data = local.user_data

  tags = {
    Name      = local.name
    Workspace = local.workspace
  }

  depends_on = [
    aws_eip.openvpn_eip,
    aws_security_group.openvpn,
  ]
}

resource "aws_eip" "openvpn_eip" {
  vpc = true
}

resource "aws_eip_association" "openvpn_eip_association" {
  instance_id   = aws_instance.openvpn_instance.id
  allocation_id = aws_eip.openvpn_eip.id
  depends_on    = [aws_eip.openvpn_eip]
}

resource "aws_network_interface" "private_vpn_nic" {
  subnet_id = var.private_subnet_id

  attachment {
    instance     = aws_instance.openvpn_instance.id
    device_index = 1
  }
}

resource "aws_security_group" "openvpn" {
  name        = "openvpn"
  description = "Allow the internet to get to the OpenVPN ports"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "udp"
    from_port   = 1194
    to_port     = 1194
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

