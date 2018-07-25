variable "ami_id" {
  description = "AMI Id for the instance. Defaults to OpenVPN Access Server 'Bring your own license' version."
  default     = "ami-6d163708"
}

variable "sandbox" {
  description = "Behave as if we are running in sandbox (as opposed to prod)"
  default = true
}

variable "public_subnet_id" {
  description = "Public subnet for VPN server"
}

variable "private_subnet_id" {
  description = "Private subnet for VPN server"
}

variable "vpc_id" {
  description = "ID of the VPC to attach the VPN server to"
}

variable "key_name" {
  description = "Key pair name for EC2 SSH access"
}

variable "admin_user" {
  description = "Username for the administrative user for the OpenVPN web frontend"
}

variable "admin_password" {
  description = "Default password for the administrative user for the OpenVPN web frontend"
}

variable "local_auth" {
  description = "Should OpenVPN use itself as an authentication server?"
  default     = "true"
}

variable "reroute_dns" {
  description = "Should OpenVPN reroute all DNS traffic through the VPN?"
  default     = "false"
}

variable "reroute_gw" {
  description = "Should OpenVPN reroute all traffic through the VPN"
  default     = "false"
}

variable "ebs_volume_name" {
  description = "Block device to attach ebs data volume to"
  default     = "/dev/xvdb"
}
