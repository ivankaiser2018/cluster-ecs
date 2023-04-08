output "alb_arn" {
  value = aws_alb.alb.arn
}

output "dns_name" {
  value = aws_alb.alb.dns_name
}

output "http_listener_arn" {
  value = aws_alb_listener.alb-http.arn
}

