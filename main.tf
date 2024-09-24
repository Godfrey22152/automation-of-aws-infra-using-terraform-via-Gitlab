module "s3" {
  source      = "./s3"
  bucket_name = var.bucket_name
  name        = var.name
  environment = var.bucket_name
}

module "networking" {
  source               = "./networking"
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  cidr_public_subnet   = var.cidr_public_subnet
  eu_availability_zone = var.eu_availability_zone
  cidr_private_subnet  = var.cidr_private_subnet
}

module "security_group" {
  source = "./security-groups"
  dev_project_sg_name = "user-service-SG"
  Name_tag = "DevOps-Project-SG"
  vpc_id = module.networking.dev_project_vpc_id  
}

module "jenkins_ec2_server" {
  source                    = "./instances/jenkins_server"
  ami_id                    = var.ec2_ami_id
  instance_type             = "t2.micro"
  tag_name                  = "Jenkins:Ubuntu Linux EC2"
  jenkins_public_key        = var.jenkins_public_key
  subnet_id                 = tolist(module.networking.dev_project_public_subnets)[0]
  dev_project_sg            = [module.security_group.dev_project_sg_id]
  enable_public_ip_address  = true
  user_data_install_jenkins = file("${path.module}/runner_scripts/jenkins-installer.sh")
}

module "nexus_ec2_server" {
  source                    = "./instances/nexus_server"
  ami_id                    = var.ec2_ami_id
  instance_type             = "t2.micro"
  tag_name                  = "Nexus:Ubuntu Linux EC2"
  nexus_public_key          = var.sonarqube_public_key
  subnet_id                 = tolist(module.networking.dev_project_public_subnets)[1]
  dev_project_sg            = [module.security_group.dev_project_sg_id]
  enable_public_ip_address  = true
  user_data_install_nexus   = file("${path.module}/runner_scripts/nexus-installer.sh")
}

module "sonarqube_ec2_server" {
  source                      = "./instances/sonarqube_server"
  ami_id                      = var.ec2_ami_id
  instance_type               = "t2.micro"
  tag_name                    = "Sonarqube:Ubuntu Linux EC2"
  sonarqube_public_key        = var.nexus_public_key
  subnet_id                   = tolist(module.networking.dev_project_public_subnets)[1]
  dev_project_sg              = [module.security_group.dev_project_sg_id]
  enable_public_ip_address    = true
  user_data_install_sonarqube = file("${path.module}/runner_scripts/sonarqube-installer.sh")
}