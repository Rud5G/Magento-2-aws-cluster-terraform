# packer amazon
# pre-build custom ami from debian 11 arm

variable "brand" {}
variable "vpc_id" {}
variable "source_ami" {}
variable "skip_create_ami" {}
variable "region" {}
variable "volume_size" {}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "latest-ami" {
  skip_create_ami = "${var.skip_create_ami}"
  ami_name      = "${var.brand}-ami-${local.timestamp}"
  ami_description = "AMI for ${var.brand} - Packer Build ${local.timestamp}"
  instance_type = "c6g.large"
  region        = "${var.region}"
  source_ami    = "${var.source_ami}"
  ssh_username = "admin"
#  launch_block_device_mappings {
#    device_name = "/dev/xvda"
#    volume_size = "${var.volume_size}"
#    volume_type = "gp3"
#    delete_on_termination = true
#  }
}

build {
  name    = "latest-ami"
  sources = [
    "source.amazon-ebs.latest-ami"
  ]
  
  post-processor "manifest" {
        output = "./manifest.json"
        strip_path = true
        custom_data = {
          timestamp = "${local.timestamp}"
        }
    }
  
  provisioner "shell" {
    script       = "./build.sh"
    pause_before = "30s"
    timeout      = "10s"
 }
}
