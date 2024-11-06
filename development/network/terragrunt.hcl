include {
  path = find_in_parent_folders()
}

terraform {
  source = "../network"
}

locals {
  servicename = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
}
