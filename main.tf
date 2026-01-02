# Terraform configuration for Puppet Agent-Server setup on Ubuntu EC2

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source for Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for Puppet
resource "aws_security_group" "puppet_sg" {
  name        = "puppet-security-group"
  description = "Security group for Puppet Server and Agent"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8140
    to_port     = 8140
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "puppet-security-group"
  }
}

# Puppet Server EC2 Instance
resource "aws_instance" "puppet_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name              = var.key_name
  vpc_security_group_ids = [aws_security_group.puppet_sg.id]
  
  user_data = base64encode(templatefile("${path.module}/user-data/puppet-server-userdata.sh", {
    puppet_server_hostname = "puppetserver"
  }))

  tags = {
    Name = "puppet-server"
    Role = "puppet-server"
  }

  # Wait for instance to be ready
  provisioner "remote-exec" {
    inline = [
      "while ! systemctl is-active --quiet puppetserver; do echo 'Waiting for Puppet Server...'; sleep 10; done",
      "echo 'Puppet Server is ready!'"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

# Puppet Agent EC2 Instance
resource "aws_instance" "puppet_agent" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name              = var.key_name
  vpc_security_group_ids = [aws_security_group.puppet_sg.id]
  
  depends_on = [aws_instance.puppet_server]
  
  user_data = base64encode(templatefile("${path.module}/user-data/puppet-agent-userdata.sh", {
    puppet_server_ip       = aws_instance.puppet_server.private_ip
    puppet_server_hostname = "puppetserver"
  }))

  tags = {
    Name = "puppet-agent"
    Role = "puppet-agent"
  }
}

# Null resource for certificate signing automation
resource "null_resource" "certificate_signing" {
  depends_on = [aws_instance.puppet_server, aws_instance.puppet_agent]

  provisioner "remote-exec" {
    inline = [
      "sleep 60",  # Wait for agent to request certificate
      "sudo /opt/puppetlabs/bin/puppetserver ca sign --all",
      "echo 'Certificates signed successfully'"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = aws_instance.puppet_server.public_ip
    }
  }

  # Trigger agent run after certificate signing
  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "sudo /opt/puppetlabs/bin/puppet agent -t",
      "echo 'Puppet configuration applied successfully'"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = aws_instance.puppet_agent.public_ip
    }
  }
}