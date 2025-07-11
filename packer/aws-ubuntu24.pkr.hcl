packer {
  required_plugins {
    amazon = {
      version = "~> 1.3"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "amazon-ebs" "amazon_ubuntu24" {
  ami_name      = var.ami_name
  instance_type = var.instance_type
  region        = var.region
  source_ami    = var.source_ami
  ssh_username  = var.ssh_username
  assume_role {
    role_arn     = var.role_arn
    session_name = var.session_name
  }
}

build {
  sources = ["source.amazon-ebs.amazon_ubuntu24"]

  provisioner "ansible" {
    playbook_file = "../ansible/playbook.yml"
  }
}