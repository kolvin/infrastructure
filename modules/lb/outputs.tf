output lb_id {
  sensitive   = false
  value = aws_lb.this.id
  description = "The ID of this load balancer"
}

output lb_arn {
  sensitive   = false
  value = aws_lb.this.arn
  description = "The ARN of this load balancer"
}

output lb_dns_name {
  sensitive   = false
  value = aws_lb.this.dns_name
  description = "The DNS name of this load balancer"
}

output lb_zone_id {
  sensitive   = false
  value = aws_lb.this.zone_id
  description = "The Zone ID of this load balancer"
}