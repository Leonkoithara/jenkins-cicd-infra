packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "ubuntu_cicd_base" {
  ami_name        = "ubuntu_cicd"
  ami_description = "Image to run cicd jobs"
  ami_regions = [
    "us-east-1"
  ]
  tags = {
    owner = "Leon Joe K"
  }
  force_deregister      = true
  force_delete_snapshot = true
  instance_type         = "t3.micro"
  source_ami_filter {
    filters = {
      name = "ubuntu-pro-server/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-pro-server-20240423"
    }
    owners = ["099720109477"]
  }
  communicator  = "ssh"
  ssh_username  = "ubuntu"
  ssh_interface = "session_manager"
  ssh_timeout   = "5m"
  iam_instance_profile = "packer_instance_profile"
  subnet_filter {
    filters  = {
      "tag:Name": "main_vpc_pub_subnet"
    }
  }
}

build {
  name    = "ubuntu_cicd_build"
  sources = ["source.amazon-ebs.ubuntu_cicd_base"]
  provisioner "shell" {
    scripts = [
      "./install.sh"
    ]
  }
}
