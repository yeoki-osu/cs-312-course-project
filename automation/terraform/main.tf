provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "minecraft" {
  name        = "minecraft-sg"
  description = "Allow Minecraft and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "minecraft" {
  ami                         = "ami-05f0fc85de381bd44"
  instance_type               = "t3.medium"
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.minecraft.id]
  associate_public_ip_address = true
  tags = {
    Name = "Minecraft-Server"
  }
}