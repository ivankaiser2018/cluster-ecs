output "alb_arn" {
  value = aws_alb.alb.arn
}

output "dns_name" {
  value = aws_alb.alb.dns_name
}

output "http_listener_arn" {
  value = aws_alb_listener.alb-http.arn
}




output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = replace(aws_db_instance.rds_instance.endpoint,":9856","")
}

output "db_instance_engine_version_actual" {
  description = "The running version of the database"
  value       = aws_db_instance.rds_instance.engine_version_actual
}


output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.rds_instance.id
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = aws_db_instance.rds_instance.resource_id
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.rds_instance.db_name
}

output "db_instance_domain" {
  description = "The ID of the Directory Service Active Directory domain the instance is joined to"
  value       = aws_db_instance.rds_instance.domain
}
