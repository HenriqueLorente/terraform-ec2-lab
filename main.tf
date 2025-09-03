# =========================
# Provider
# =========================
provider "aws" {
  region  = var.aws_region
  profile = "outra-conta"
}

# =========================
# (Opcional) Security Group
# =========================
resource "aws_security_group" "web_sg" {
  count       = var.create_sg ? 1 : 0
  name        = "ec2-lab-sg"
  description = "HTTP/SSH para lab"
  vpc_id      = var.vpc_id

  # HTTP 80
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.ingress_cidr]
  }

  # (Opcional) SSH 22 — se quiser acesso por SSH
  # ingress {
  #   description = "SSH"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = [var.ingress_cidr] # ou SEU_IP/32
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ec2-lab-sg" }
}

# =========================
# Instância EC2
# =========================
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type

  # Se você informar key_name, usa; se deixar "", não seta (sem SSH)
  key_name = var.key_name != "" ? var.key_name : null

  # Se criou SG, usa; senão deixa null p/ cair no security group default da VPC
  vpc_security_group_ids = var.create_sg ? [aws_security_group.web_sg[0].id] : (var.security_group_id != "" ? [var.security_group_id] : null)


  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "ec2-lab-t2micro"
    Lab  = "terraform-wsl"
  }
}
