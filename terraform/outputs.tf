output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "load_balancer_dns_name" {
  value = aws_lb.internet_facing_load_balancer.dns_name
}
