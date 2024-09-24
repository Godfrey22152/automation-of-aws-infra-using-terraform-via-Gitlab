variable "ami_id" {}
variable "instance_type" {}
variable "tag_name" {}
variable "subnet_id" {}
variable "dev_project_sg" {}
variable "enable_public_ip_address" {}
variable "user_data_install_sonarqube" {}
variable "sonarqube_public_key" {}

output "ssh_connection_string_for_sonarqube_ec2" {
  value = format("%s%s", "ssh -i /home/odo/.ssh/sonarqube_ec2_terraform_key ubuntu@", aws_instance.sonarqube_ec2_server.public_ip)
}

output "sonarqube_ec2_server" {
  value = aws_instance.sonarqube_ec2_server.id
}

output "sonarqube_ec2_instance_public_ip" {
  value = aws_instance.sonarqube_ec2_server.public_ip
}

# keyPair resource
resource "aws_key_pair" "sonarqube_ec2_instance_public_key" {
  key_name   = "sonarqube_ec2_terraform_key"
  public_key = var.sonarqube_public_key
}

# Sonarqube_EC2_Server Resource
resource "aws_instance" "sonarqube_ec2_server" {
  ami                     = var.ami_id
  instance_type           = var.instance_type
  tags = {
    Name = var.tag_name
  }
  key_name                    = aws_key_pair.sonarqube_ec2_instance_public_key.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.dev_project_sg
  associate_public_ip_address = var.enable_public_ip_address
  
  user_data                   = var.user_data_install_sonarqube

  metadata_options {
    http_endpoint = "enabled"  # Enable the IMDSv2 endpoint
    http_tokens   = "required" # Require the use of IMDSv2 tokens
  }
}


  
