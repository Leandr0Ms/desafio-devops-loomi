variable "name" {
  description = "Nome do banco de dados"
  type        = string
}

variable "db_name" {
  description = "Nome do schema padrão"
  type        = string
}

variable "username" {
  description = "Usuário do banco"
  type        = string
}

variable "password" {
  description = "Senha do banco"
  type        = string
  sensitive   = true
}

variable "subnet_ids" {
  description = "IDs das subnets privadas"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "Security Groups para permitir acesso ao banco"
  type        = list(string)
}

variable "instance_class" {
  description = "Tipo da instância RDS"
  type        = string
  default     = "db.t3.micro"
}
