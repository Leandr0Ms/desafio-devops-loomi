output "endpoint" {
  description = "Endpoint do banco RDS"
  value       = aws_db_instance.this.endpoint
}

output "db_name" {
  value = aws_db_instance.this.db_name
}
