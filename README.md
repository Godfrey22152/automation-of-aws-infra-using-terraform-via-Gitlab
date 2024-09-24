# Terraform AWS Infrastructure Project with GitLab CI/CD Pipeline

This project is a Terraform-based infrastructure as code (IaC) setup for deploying and managing AWS resources, with a GitLab CI/CD pipeline for automation. It provisions an AWS Virtual Private Cloud (VPC), Subnets, Security Groups, and EC2 instances for Jenkins, Nexus, and SonarQube servers. Additionally, the project implements a CI/CD pipeline in GitLab to validate, plan, and apply the Terraform configuration.

## Table of Contents
- [Infrastructure Overview](#infrastructure-overview)
- [Project Structure](#project-structure)
- [Terraform Setup](#terraform-setup)
- [CI/CD Pipeline Overview](#cicd-pipeline-overview)
- [Usage](#usage)
- [Requirements](#requirements)
- [Outputs](#outputs)
- [Contact](#contact)

---

## Infrastructure Overview

The project provisions the following infrastructure on AWS:
- **VPC**: A Virtual Private Cloud with public and private subnets.
- **Subnets**: Public and private subnets for high availability across availability zones.
- **Security Groups**: Security Groups to control inbound and outbound traffic for the EC2 instances.
- **EC2 Instances**: Separate instances for Jenkins, Nexus, and SonarQube services.
  
The project also sets up necessary routes, internet gateways, and other networking components.

---

## Project Structure

The Terraform configuration is organized in modules for each major component:
- `s3/`: For provisioning S3 bucket.
- `networking/`: For setting up the VPC, subnets, and routing.
- `security-groups/`: Contains security groups and related rules.
- `instances/`: Contains configuration for EC2 instances running Jenkins, Nexus, and SonarQube.
- `runner_scripts/`: Scripts for installing Jenkins, Nexus, and SonarQube on the respective instances.

## Directory Structure 
```bash
.
├── s3/
├── networking/
├── security-groups/
├── instances/
│   ├── jenkins_server/
│   ├── nexus_server/
│   └── sonarqube_server/
├── runner_scripts/
├── provider.tf
├── remote_backend_s3.tf
├── .gitlab-ci.yml
├── variables.tf
├── terraform.tfvars
└── main.tf
```
---

## Terraform Setup

The main `main.tf` file configures and provisions the resources:
```hcl
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
```
---
## CI/CD Pipeline Overview

The GitLab CI/CD pipeline, defined in `.gitlab-ci.yml`, automates the following tasks:

- **Validation**: Runs `terraform validate` to ensure the Terraform code is syntactically correct.
- **Plan**: Generates an execution plan using `terraform plan` and stores it as an artifact.
- **Apply**: Applies the Terraform plan (manual trigger).
- **Destroy**: Optionally destroys the infrastructure (manual trigger).

## Pipeline Configuration
Here’s the `.gitlab-ci.yml` file:

```bash
image:
  name: registry.gitlab.com/gitlab-org/gitlab-build-images:terraform
  entrypoint:
  - "/usr/bin/env"
  - PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
variables:
  AWS_ACCESS_KEY_ID: "${MY_AWS_ACCESS_KEY}"
  AWS_SECRET_ACCESS_KEY: "${MY_AWS_SECRET_ACCESS_KEY}"
  AWS_DEFAULT_REGION: eu-west-1
before_script:
- terraform --version
- terraform init
stages:
- ".pre"
- validate
- plan
- apply
- destroy
- ".post"
validate:
  stage: validate
  script:
  - terraform validate
plan:
  stage: plan
  dependencies:
  - validate
  script:
  - terraform plan -out="planfile"
  artifacts:
    paths:
    - planfile
apply:
  stage: apply
  dependencies:
  - plan
  script:
  - terraform apply -input=false "planfile"
  when: manual
destroy:
  stage: destroy
  script:
  - terraform destroy --auto-approve
  when: manual
```
## GitLab Pipeline Stages

The GitLab CI/CD pipeline automates the process of provisioning and managing infrastructure. Each stage handles different aspects of the process:

- **Validate Stage**: Ensures that the Terraform files are syntactically correct by running `terraform validate`.
- **Plan Stage**: Creates a plan outlining the changes that Terraform will make, using `terraform plan`. The plan details the actions Terraform will take to achieve the desired infrastructure state and is stored as an artifact.
- **Apply Stage**: Applies the Terraform execution plan to provision resources in AWS. This stage requires a manual trigger in GitLab.
- **Destroy Stage**: Optionally destroys the infrastructure by running `terraform destroy`. This stage is also triggered manually.

---

## Usage

### Pre-requisites

- **Terraform**: Ensure Terraform is installed on your local machine. You can install it by following the [official guide](https://learn.hashicorp.com/tutorials/terraform/install-cli).
- **AWS CLI**: Install and configure AWS CLI to interact with your AWS account. [AWS CLI installation guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).
- **AWS Credentials**: Set up your AWS credentials by exporting `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as environment variables, or by configuring the AWS CLI:

    ```bash
    export AWS_ACCESS_KEY_ID=<your-access-key>
    export AWS_SECRET_ACCESS_KEY=<your-secret-key>
    ```
    Alternatively, run `aws configure` to set up credentials locally.

- **GitLab CI Runner**: Ensure you have a GitLab CI runner available to run the pipeline or use GitLab's shared runners. Check the [GitLab Runner installation guide](https://docs.gitlab.com/runner/install/) for more details.

---

### Running Terraform Locally

#### Steps:

1. **Clone the repository** to your local environment:

    ```bash
    git clone https://github.com/Godfrey22152/automation-of-aws-infra-using-terraform-via-Gitlab.git
    cd automation-of-aws-infra-using-terraform-via-Gitlab
    ```

2. **Initialize Terraform**: This sets up the working directory with the necessary configuration and downloads any required plugins or modules:

    ```bash
    terraform init
    ```

3. **Validate the configuration** to ensure the syntax is correct:

    ```bash
    terraform validate
    ```

4. **Create an execution plan**: This will show you what actions Terraform will perform without making any actual changes:

    ```bash
    terraform plan 
    ```

5. **Apply the plan**: Provision the resources as defined in your Terraform configuration:

    ```bash
    terraform apply --auto-approve
    ```

6. **To destroy the infrastructure** when no longer needed:

    ```bash
    terraform destroy --auto-approve
    ```

---

### Running Terraform with GitLab CI/CD

GitLab CI/CD automates the entire process of infrastructure management using the `.gitlab-ci.yml` file. Here's how you can use GitLab CI/CD to run the Terraform code.

#### Steps:

1. **Clone the repository** to your local machine, make changes, and push them to GitLab:

    ```bash
    git clone https://gitlab.com/infra-automation3/automation-of-aws-infra-using-terraform.git
    cd infra-automation3/automation-of-aws-infra-using-terraform
    git add .
    git commit -m "Your commit message"
    git push origin <branch-name>
    ```

2. **GitLab Pipeline Execution**:

    - Once changes are pushed to GitLab, the CI/CD pipeline automatically triggers the following stages:
    
        - **Validate**: Terraform files are checked for syntax errors using `terraform validate`.
        - **Plan**: Terraform creates an execution plan using `terraform plan`. The plan file will be stored as an artifact.
    
    - After validation and planning, you can **manually trigger** the following stages:
    
        - **Apply**: This stage provisions the infrastructure defined in your Terraform files by running `terraform apply`.
        - **Destroy**: If you want to tear down your infrastructure, you can manually trigger this stage which runs `terraform destroy`.

3. **Monitoring the Pipeline**: Go to your GitLab repository's CI/CD section to monitor the pipeline stages. You'll see each step (Validate, Plan, Apply, Destroy) executed in sequence, and you can view logs to troubleshoot any issues.

4. **Triggering Manual Jobs**:
    - Once the pipeline finishes the Validate and Plan stages, manual intervention is required to run Apply or Destroy.
    - You can trigger these jobs from the GitLab CI/CD pipeline page by clicking on the "play" button next to the relevant job.

---

## Requirements

- **Terraform**: Version 0.12+ is required to ensure compatibility with the codebase.
- **AWS CLI**: Ensure you have AWS CLI installed and set up with valid credentials.
- **GitLab CI/CD**: You must configure GitLab CI with runners available to run the pipeline.

---

## Outputs

After successful execution of the Terraform code, the following key infrastructure details will be outputted:

- **VPC ID**: Identifier of the created VPC.
- **Public and Private Subnet IDs**: List of subnet IDs for both public and private subnets.
- **Security Group ID**: The identifier of the created security group.

---

## Contact

If you have any questions or need further assistance, please reach out to:

- **Maintainer**: GODFREY
- **Email**: godfreyifeanyi50@gmail.com
