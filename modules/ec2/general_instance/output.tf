output "instance_private_dns" {
  value = aws_instance.this.private_dns
}

output "instance_id" {
  value = aws_instance.this.id
}

output "tags_all" {
  value = aws_instance.this.tags_all
}
