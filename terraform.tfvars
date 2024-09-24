
bucket_name = "dev-project-remote-state-bucket-22152"
name        = "environment"
environment = "dev"

vpc_cidr             = "11.0.0.0/16"
vpc_name             = "DevOps-Project-VPC"
cidr_public_subnet   = ["11.0.1.0/24", "11.0.2.0/24"]
cidr_private_subnet  = ["11.0.3.0/24", "11.0.4.0/24"]
eu_availability_zone = ["eu-west-1a", "eu-west-1b"]

jenkins_public_key   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0gS81clPD18J2bgZCHzriQbx53soRoFh9WfFaMCHza Jenkins-KeyPair"
sonarqube_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH3AHXZlHBBeLomkM0B5x9ik24VP6pBxusEqbH8WQQtZ Sonarqube-KeyPair"
nexus_public_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJvRuyZDzbzSBWA3qFy7MfQBi1KAwuYcJVWdpp5LyJND Nexus-KeyPair"
ec2_ami_id           = "ami-03cc8375791cb8bcf"

