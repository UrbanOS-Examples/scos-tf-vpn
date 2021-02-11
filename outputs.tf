output "elastic_ip" {
  description = "Elastic IP address of the OpenVPN instance"
  value       = aws_eip.openvpn_eip.public_ip
}

output "private_subnet_ip" {
  description = "Private subnet IP address for the OpenVPN EC2 instance"
  value       = aws_network_interface.private_vpn_nic.private_ip
}

output "ec2_instance_id" {
  description = "EC2 Instance ID for the OpenVPN instance"
  value       = aws_instance.openvpn_instance.id
}

