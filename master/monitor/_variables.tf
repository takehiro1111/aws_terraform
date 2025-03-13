variable "lambda" {
  type = map(any)
  default = {
    "csv-aggregate" : { "filter-pattern" : "?ERROR ?Exception" },
  }
}
