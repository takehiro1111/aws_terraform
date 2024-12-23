# ECS自動停止イベントルール
resource "aws_cloudwatch_event_rule" "this" {
  name                = var.name
  state               = var.state
  description         = "ecs service stop automation runbook"
  schedule_expression = var.schedule_expression
}

# ECS自動停止イベントターゲット
# arnに渡す際にreplaceしているが、これはterraform側のバグautomationを使用する際の形式が違うため手動で変更してあげる必要がある
# Ref: https://github.com/hashicorp/terraform-provider-aws/issues/6461
resource "aws_cloudwatch_event_target" "this" {
  for_each  = toset(var.ecs_service_list)

  target_id = each.key
  rule      = aws_cloudwatch_event_rule.this.name
  arn       = replace(data.aws_ssm_document.this.arn, "document/", "automation-definition/")
  role_arn  = data.aws_iam_role.this.arn
  input     = jsonencode({
    EcsClusterName = [var.ecs_cluster_name]
    EcsServiceName = [each.key]
  })
}

# SSM Automation用
data aws_iam_role this {
  name = "ecs-auto-control"
}

# ECS 自動停止用のSSM
data aws_ssm_document this {
  name            = "StopEcs"
  document_format = "YAML"
}
