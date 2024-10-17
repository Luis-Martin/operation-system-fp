# Final Project - Operating Systems Course

Final project for the operating systems course, where we assess the security of two Debian operating systems on Google Cloud Platform using the Lynis tool.

## Prerequisites

Before starting, make sure you have the following:

- An active Google Cloud Platform (GCP) account.
- A project selected in GCP where the infrastructure will be deployed.
- Installed locally or using Google Cloud Shell.

## Cloning the Project

1. Clone the GitHub Repository

```bash
 git clone https://github.com/Luis-Martin/operation-system-fp
```

2. Navigate to the project directory

```bash
cd operation-system-fp
```

## Project Structure

main.tf: Terraform configuration file that defines the resources needed for the project, including the custom network, firewall rules, and two virtual machines (target and reference) running Debian.

## Steps to Deploy the Infrastructure

1. Open Google Cloud Shell

2. Initialize Terraform (First time only)

```bash
terraform init
```

3. Plan the Terraform deployment

```bash
terraform plan
```

4. Apply the Terraform plan

```bash
terraform apply
```

5. Testing the Environment

Once the deployment is complete, you can connect to the virtual machines via SSH.

6. Destroy the Infrastructure

```bash
terraform destroy
```

