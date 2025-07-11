variable "ami_name" {
  type    = string
  default = "packer-amazon_ubuntu24-{{timestamp}}"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "source_ami" {
  type    = string
  default = "ami-044415bb13eee2391"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "role_arn" {
  type    = string
}

variable "session_name" {
  type    = string
  default = "packer-session"
}