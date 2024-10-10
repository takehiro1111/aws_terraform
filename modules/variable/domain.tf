/* 
 * takehiro1111.com
 */
output "takehiro1111_com" {
  description = "お名前.comで取得した検証用ドメイン"
  value = "takehiro1111.com"
}

output "wildcard_takehiro1111_com" {
  description = "ACMで参照するためにドメインをワイルドカードで指定"
  value = "*.takehiro1111.com"
}

output "cdn_takehiro1111_com" {
  description = "CloudFrontのaliasで設定"
  value = "cdn.takehiro1111.com"
}

