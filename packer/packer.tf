variable "skip_create_ami" {}

locals { packer_ami = element(values(data.external.packer.result), 0) }

resource "null_resource" "packer" {
  triggers = {
    aws_ami_id = data.aws_ami.distro.id
  }

  provisioner "local-exec" {
    working_dir = "./packer"
    command = <<EOF

/usr/bin/packer build \
  -var skip_create_ami=${var.skip_create_ami} \
  -var region=${data.aws_region.current.name} \
  -var vpc_id=${aws_vpc.this.id} \
  -var source_ami=${data.aws_ami.distro.id} \
  -var brand=${var.app["brand"]} \
  packer.pkr.hcl

EOF
  }
}

data "external" "packer" {
   depends_on = [null_resource.packer]
   program = ["/bin/bash", "./packer/ami_id.sh"]
  }
