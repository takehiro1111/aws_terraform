variable "cidr_block" {
  type = map(string)
  default = {
    public_1a  = "10.0.1.0/24"
    private_1a = "10.0.2.0/24"
  }
}


