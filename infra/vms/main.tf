########################################
# 🔧 DADOS DA REDE E AMI
########################################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  # Filtra subnets padrão (públicas)
  filter {
    name   = "default-for-az"
    values = ["true"]
  }

  # Garante que usaremos AZs compatíveis com Free Tier (como us-east-1a ou 1b)
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
# 🔒 GRUPOS DE SEGURANÇA
########################################

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow SSH/HTTP/HTTPS"
  vpc_id      = data.aws_vpc.default.id

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

resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow PostgreSQL from app-sg"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "Postgres from app-sg"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################################
# ⚙️ USER DATA (Configuração inicial)
########################################

locals {
  app_user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx ufw docker.io
    systemctl enable nginx docker
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    echo "y" | ufw enable
    cat >/etc/nginx/sites-available/app.conf <<'NGINX'
    server {
      listen 80;
      location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
      }
    }
    NGINX
    rm -f /etc/nginx/sites-enabled/default
    ln -s /etc/nginx/sites-available/app.conf /etc/nginx/sites-enabled/
    nginx -t && systemctl restart nginx
  EOF

  db_user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y postgresql postgresql-contrib ufw
    sed -i "s/^#*listen_addresses.*/listen_addresses = '*'/" /etc/postgresql/*/main/postgresql.conf
    echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/*/main/pg_hba.conf
    systemctl enable postgresql
    systemctl restart postgresql
    sudo -u postgres psql -c "CREATE ROLE fastapi WITH LOGIN PASSWORD 'fastapi';"
    sudo -u postgres psql -c "CREATE DATABASE fastapi_db OWNER fastapi;"
    ufw allow 22/tcp
    ufw allow 5432/tcp
    echo "y" | ufw enable
  EOF
}

########################################
# 🖥️ INSTÂNCIAS EC2
########################################

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.app_instance_type
  key_name               = aws_key_pair.devops.key_name
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data              = local.app_user_data
  tags                   = { Name = "desafio-app" }
}

resource "aws_eip" "app_eip" {
  instance = aws_instance.app.id
  domain   = "vpc"
  tags     = { Name = "desafio-app-eip" }
}

resource "aws_instance" "db" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.db_instance_type
  key_name               = aws_key_pair.devops.key_name
  subnet_id              = data.aws_subnets.default.ids[1]
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  user_data              = local.db_user_data
  tags                   = { Name = "desafio-db" }
}

########################################
# 📤 OUTPUTS
########################################

output "app_public_ip" {
  description = "IP público da VM de aplicação (com EIP)"
  value       = aws_eip.app_eip.public_ip
}

output "db_private_ip" {
  description = "IP privado da VM de banco de dados"
  value       = aws_instance.db.private_ip
}

output "db_public_ip" {
  description = "IP público da VM de banco de dados"
  value       = aws_instance.db.public_ip
}

output "ssh_app" {
  description = "Comando SSH para conectar na VM App"
  value       = "ssh -i ~/.ssh/id_ed25519 ubuntu@${aws_eip.app_eip.public_ip}"
}

output "ssh_db" {
  description = "Comando SSH para conectar na VM DB"
  value       = "ssh -i ~/.ssh/id_ed25519 ubuntu@${aws_instance.db.public_ip}"
}