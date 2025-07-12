variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "prefix" {
  description = "Prefix for all tags"
  type        = string
  default     = "weather-app"
}

variable "vpc_cidr" {
  type    = string
  default = "172.16.0.0/16"
}

variable "subnet_cidrs" {
  type    = list(string)
  default = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "packer_created_ami" {
  description = "value of the AMI created by Packer"
  type        = string
  default = "packer-amazon_ubuntu24.04-*"
}
