# =================================
# データ型
# =================================
# my_favorite_sports = var.list[0]
variable "list" {
  description = "中身の要素が全て同じ型の配列"
  type        = list(string)
  default     = ["soccer", "basseball"]
}

# [for i in var.set : upper(i)]
variable "set" {
  description = "中身の要素の重複が削除される配列"
  type        = set(string)
  default = [
    "orange",
    "banana",
    "apple",
    "banana"
  ]
}

# my_age = var.tuple[1]
variable "tuple" {
  description = "中身の要素に順序性を持たない配列"
  type = tuple([
    string, number
  ])
  default = ["age", 29]
}

# github = var.object.name
variable "object" {
  description = "Key,Value形式のデータ型で最初にobject関数でキー、バリューの型を定義する"
  type = object({
    name = string
    age  = number
  })
  default = {
    name = "takehiro1111"
    age  = 29
  }
}

# github = var.map.user
variable "map" {
  description = "Keyが文字列でValueが指定された型になる配列"
  type        = map(string)
  default = {
    "user" = "takehiro1111"
    "age"  = "29"
  }
}

variable "restriction_cloudfront_stg" {
  type        = map(string)
  description = "ALBへのアクセスを、CloudFront経由に限定するためのカスタムヘッダー"

  default = {
    key   = "X-From-Restriction-Cloudfront"
    value = "TczzzPXeBsCsz3ksaaag"
  }
}

variable "prometheus_sg_inbound_rule" {
  description = "SGのインバウンドルールのポート"
  type        = list(string)
  default = [
    "80", "443", "22", "9090", "3000", "9100"
  ]
}

variable "start_rds" {
  description = "RDSインスタンスを作成する場合はtrue"
  type        = bool
  default     = false
}

variable "start_aurora" {
  description = "Auroraに関連するリソースを作成したい場合はtrue"
  type        = bool
  default     = false
}

variable "start_ec2_francfurt" {
  type    = bool
  default = false
}

variable "user_name" {
  description = "IAMユーザー名"
  type        = set(string)
  default = [
    "sato",
    "suzuki",
    "tanaka",
    "sato",
  ]
}

// mapは同じ型で定義しないといけない。
variable "example_map" {
  type = map(string)
  default = {
    key1 = "value1",
    key2 = "value2",
    key3 = "value3"
  }
}

// 数値型のmap
variable "example_map_numbers" {
  type = map(number)
  default = {
    key1 = 1,
    key2 = 2,
    key3 = 3
  }
}

// オブジェクトはプロパティごとに型を宣言する事で型を混在して扱える。
variable "multi_array" {
  type = object({
    property1 = string
    property2 = number
    property3 = bool
  })
  default = {
    property1 = "string value"
    property2 = 42
    property3 = true
  }
}


variable "names" {
  type    = list(string)
  default = ["neo", "trinity", "move"]
}

output "variables_name" {
  value = "%{for element, value in var.names} (${element}) ${value}, %{endfor}"
}
