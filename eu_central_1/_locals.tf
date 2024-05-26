locals {
  ingress_web = [
    ["HTTP", 80, 80, "tcp", "${chomp(data.http.myip.body)}/32"],
    ["HTTPS", 443, 443, "tcp", "${chomp(data.http.myip.body)}/32"],
    ["SSH", 22, 22, "tcp", "${chomp(data.http.myip.body)}/32"],
  ]
}
