variable "ami_id" {}
variable "instance_type" {}
variable "tag_name" {}
variable "subnet_id" {}
variable "dev_project_sg" {}
variable "enable_public_ip_address" {}
variable "user_data_install_nexus" {}
variable "nexus_public_key" {}

output "ssh_connection_string_for_nexus_ec2" {
  value = format("%s%s", "ssh -i /home/odo/.ssh/nexus_ec2_terraform_key ubuntu@", aws_instance.nexus_ec2_server.public_ip)
}

output "nexus_ec2_server" {
  value = aws_instance.nexus_ec2_server.id
}

output "nexus_ec2_instance_public_ip" {
  value = aws_instance.nexus_ec2_server.public_ip
}

# KeyPair resource
resource "aws_key_pair" "nexus_ec2_instance_public_key" {
  key_name   = "nexus_ec2_terraform_key"
  public_key = var.nexus_public_key
}

# Nexus_server_EC2 resource
resource "aws_instance" "nexus_ec2_server" {
  ami                     = var.ami_id
  instance_type           = var.instance_type
  tags = {
    Name = var.tag_name
  }
  key_name                    = aws_key_pair.nexus_ec2_instance_public_key.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.dev_project_sg
  associate_public_ip_address = var.enable_public_ip_address

  user_data                   = var.user_data_install_nexus

  metadata_options {
    http_endpoint = "enabled"  # Enable the IMDSv2 endpoint
    http_tokens   = "required" # Require the use of IMDSv2 tokens
  }
}

  
