########################################
# 🔧 DADOS DA REDE E AMI
########################################

# VPC usada pelo EKS e EC2
data "aws_vpc" "main" {
  id = "vpc-0280efeb976aaa4e7"
}


data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

########################################
# 🔑 CHAVE SSH
########################################

resource "aws_key_pair" "devops" {
  key_name   = "devops-wsl"
  public_key = file("~/.ssh/id_ed25519.pub")
}

########################################
# 🔒 SECURITY GROUPS
########################################

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow SSH/HTTP/HTTPS"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

########################################
# 🖥️ INSTÂNCIA DE APLICAÇÃO (opcional)
########################################

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.app_instance_type
  key_name               = aws_key_pair.devops.key_name
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  tags                   = { Name = "desafio-app" }
}

# Subnet privada A (em us-east-1a)
resource "aws_subnet" "private_a" {
  vpc_id                  = "vpc-0280efeb976aaa4e7"
  cidr_block              = "172.31.96.0/20"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-a"
  }
}

# Subnet privada B (em us-east-1b)
resource "aws_subnet" "private_b" {
  vpc_id                  = "vpc-0280efeb976aaa4e7"
  cidr_block              = "172.31.112.0/20"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-b"
  }
}


########################################
# ☁️ MÓDULO RDS (PostgreSQL gerenciado)
########################################

module "rds" {
  source = "./modules/rds"

  name                   = "desafio-loomi-db"
  db_name                = "fastapi_db"
  username               = "fastapi"
  password               = "loomi123"

  # Subnets privadas da VPC correta
  subnet_ids             = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  # SG da EC2 (que está na mesma VPC)
  vpc_security_group_ids = ["sg-0c8b97161ed4195c4"]
}

########################################
# 📤 OUTPUTS
########################################

output "app_public_ip" {
  description = "IP público da VM de aplicação"
  value       = aws_instance.app.public_ip
}

output "rds_endpoint" {
  description = "Endpoint do banco de dados RDS"
  value       = module.rds.endpoint
}

output "ssh_app" {
  description = "Comando SSH para conectar na VM App"
  value       = "ssh -i ~/.ssh/id_ed25519 ubuntu@${aws_instance.app.public_ip}"
}
