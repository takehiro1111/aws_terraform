locals {
  servicename = "hashicorp"
  env         = "stg"
  repository  = "hashicorp"
  directory   = "sekigaku/hashicorp"

  accounnt_id = data.aws_caller_identity.current.id

  # CloudFront Origin ID
  ecs_origin_id = "ALB-ecs"

  # AuroraのCluster識別子
  idetifier_aurora_cluster = "aurora-cluster"

  # AMIを参照する際に使用
  aws_owner = "137112412989"

  # ECS
  main = "main-ecs"
  api  = "api-ecs"
}
