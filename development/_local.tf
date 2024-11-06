locals {
  # CloudFront Origin ID
  ecs_origin_id = "ALB-ecs"

  # AuroraのCluster識別子
  idetifier_aurora_cluster = "aurora-cluster"

  # ECS
  main = "main-ecs"
  api  = "api-ecs"
}
