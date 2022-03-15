provider "aws" {
  region = local.region
}

locals {
  name   = "jenkins-dev"
  region = "eu-west-1"

  user_data = <<-EOT
    #!/bin/bash
    echo "Hello Terraform!"
    EOT

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

######## Networking #########



resource "aws_vpc" "vpc" {
  cidr_block           = "10.99.0.0/18"
  enable_dns_hostnames = true
  tags                 = local.tags

}

resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.99.0.0/24"
  availability_zone = "${local.region}a"
  tags              = local.tags
}

resource "aws_route_table" "public-subnet-route-table" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.tags
}

resource "aws_route" "public-subnet-route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.public-subnet-route-table.id
}

resource "aws_route_table_association" "public-subnet-route-table-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-subnet-route-table.id
}



resource "aws_security_group" "jenkins_sg" {
  name        = local.name
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "TLS-jenkins from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_placement_group" "web" {
  name     = local.name
  strategy = "spread"
}

resource "aws_kms_key" "this" {
}


resource "aws_key_pair" "jenkins" {

  key_name   = "jenkins"
  public_key = file("jenkins.pub")

  tags = {
    Terraform = "<3"
  }
}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2", ]
  }
}

/* resource "aws_network_interface" "this" {
    subnet_id = element(module.vpc.private_subnets, 0)
} */

################### EC2 Module ##################



resource "aws_instance" "ec2_jenkins" {

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  availability_zone      = aws_subnet.public-subnet.availability_zone
  subnet_id              = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  #placement_group             = aws_placement_group.web.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.jenkins.key_name

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./secrets/jenkins")
    host        = self.public_dns
    timeout     = "4m"
  
  }

  provisioner "file" {
    source      = "tmp/script.sh"
    destination = "/tmp/script.sh"
  
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/script.sh",
      "sudo /tmp/script.sh",
    ]
  }


  #user_data_base64 = base64encode(local.user_data)

  root_block_device {
    volume_type = "gp2"
    volume_size = 10
    tags = {
      Name = "my-root-block"
    }
  }

  ebs_block_device {
    device_name           = "xvdd"
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = 10
  }
  tags = local.tags
}
