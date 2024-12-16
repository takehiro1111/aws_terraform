/* 
 * takehiro1111.com
 */
output "takehiro1111_com" {
  description = "お名前.comで取得した検証用ドメイン"
  value       = "takehiro1111.com"
}

output "wildcard_takehiro1111_com" {
  description = "ACMで参照するためにドメインをワイルドカードで指定"
  value       = "*.takehiro1111.com"
}

output "cdn_takehiro1111_com" {
  description = "CloudFrontのaliasで設定"
  value       = "cdn.takehiro1111.com"
}

output "api_takehiro1111_com" {
  description = "CloudFrontのaliasで設定"
  value       = "api.takehiro1111.com"
}

output "prometheus_takehiro1111_com" {
  description = "Prometheus用EC2のドメイン"
  value       = "prometheus.takehiro1111.com"
}

output "grafana_takehiro1111_com" {
  description = "Prometheus用EC2のドメイン"
  value       = "grafana.takehiro1111.com"
}

output "locust_takehiro1111_com" {
  description = "LOCUST用ドメイン"
  value       = "locust.takehiro1111.com"
}

