variable "bucket_name" {
  type        = string
  description = "Remote state bucket name"
}

variable "name" {
  type        = string
  description = "Tag name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vpc_cidr" {
  type        = string
  description = "Public Subnet CIDR values"
}

variable "vpc_name" {
  type        = string
  description = "DevOps Project VPC"
}

variable "cidr_public_subnet" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "cidr_private_subnet" {
  type        = list(string)
  description = "Private Subnet CIDR values"
}

variable "eu_availability_zone" {
  type        = list(string)
  description = "Availability Zones"
}

variable "jenkins_public_key" {
  type        = string
  description = "DevOps Project Public key for Jenkins EC2 instances"
}

variable "sonarqube_public_key" {
  type        = string
  description = "DevOps Project Public key for Sonarqube EC2 instances"
}

variable "nexus_public_key" {
  type        = string
  description = "DevOps Project Public key for Nexus EC2 instances"
}

variable "ec2_ami_id" {
  type        = string
  description = "DevOps Project 1 AMI Id for EC2 instances"
}

