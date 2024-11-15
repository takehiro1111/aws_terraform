output "td_vpc_endpoint_service_service_name" {
  description = "Service name of the VPC endpoint service for td-agent"
  value       = aws_vpc_endpoint_service.td_agent.service_name
}
