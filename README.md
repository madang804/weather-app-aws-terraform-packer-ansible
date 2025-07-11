# Weather App with Terraform Deployment

![License](https://img.shields.io/badge/license-MIT-blue.svg)
A simple web API built with Python and Flask that provides weather-related information, deployed to auto scaled and load balanced AWS EC2 target using Terraform.

## Project Overview

![weather-app-aws-terraform-packer-ansible.png](.weather-app-aws-terraform-packer-ansible.png)

This project consists of:
- A Python Flask application that serves weather data via API endpoints
- Packer and Ansible to create custom AMI that automatically start a service to run the app on boot
- Terraform to build the infrastructure and deploy the custom AMI to EC2 target to host the web app
- Hashicorp cloud platform to store Terraform state file
- GitHub Actions CI/CD pipeline for automated deployment

## API Endpoints

- `GET /` - Homepage
- `GET /api/v1.0/weather?location=<location>` - Get complete weather data
- `GET /api/v1.0/temperature?location=<location>` - Get temperature data
- `GET /api/v1.0/wind?location=<location>` - Get wind data
- `GET /api/v1.0/humidity?location=<location>` - Get humidity data

## Prerequisites

- Python 3.9+
- Packer
- Ansible
- Terraform
- Hashicorp cloud platform account
- AWS account with appropriate permissions
- GitHub account

## CI/CD Pipeline

The GitHub Actions workflow performs the following steps:
- Build Custom AMI: Build custom image using packer and ansible provisioner in AWS
- Build and Deploy: Build and deploy infrastructure to host web app in AWS
- Endpoint Testing: Tests all API endpoints after deployment
- Clean-up: Optionally destroys resources after testing

## Environment Variables

Required environment variables for deployment:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- TF_TOKEN_app_terraform_io (Hashicorpt Cloud API token)

These should be set as GitHub Secrets in your repository settings.

## Testing

Run a script to test endpoints

## License

This project is licensed under the terms of the MIT License. See [LICENSE](./LICENSE) for more details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
