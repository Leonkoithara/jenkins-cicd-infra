data "aws_ami" "ubuntu_cicd_ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu_cicd"]
  }
}

data "aws_kms_key" "aws_ebs_key" {
  key_id = "alias/aws/ebs"
}

resource "aws_instance" "jenkins_host" {
  ami                         = data.aws_ami.ubuntu_cicd_ami.id
  associate_public_ip_address = true
  root_block_device {
    encrypted   = true
    kms_key_id  = data.aws_kms_key.aws_ebs_key.arn
    volume_size = 16
    volume_type = "gp2"
    tags = {
      Name = "CICD Host dev"
    }
  }
  iam_instance_profile = aws_iam_instance_profile.packer_profile.name
  instance_type = "t3.micro"
  subnet_id = aws_subnet.main_vpc_pub_subnet.id
  tags = {
    Name = "CICD Host"
  }
  vpc_security_group_ids = [
    aws_security_group.public_instance_sg.id
  ]
}

output "ami_id" {
  value = data.aws_ami.ubuntu_cicd_ami.id
}

output "aws_ebs_key_id" {
  value = data.aws_kms_key.aws_ebs_key.id
}