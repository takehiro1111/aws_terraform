/**
 * ECS 自動起動用のSSM
 */
resource "aws_ssm_document" "start_ecs" {
  name            = "StartEcs"
  document_type   = "Automation"
  document_format = "YAML"

  content = <<YAML
    description: ecs service start automation runbook
    schemaVersion: '0.3'
    parameters:
      EcsClusterName:
        type: String
      EcsServiceName:
        type: String
      DesiredCount:
        type: Integer
        default: 1
    mainSteps:
      - name: ECS
        action: 'aws:executeAwsApi'
        inputs:
          Service: ecs
          Api: UpdateService
          cluster: '{{ EcsClusterName }}'
          service: '{{ EcsServiceName }}'
          desiredCount: '{{ DesiredCount }}'
  YAML
}

/**
 * ECS 自動停止用のSSM
 */
resource "aws_ssm_document" "stop_ecs" {
  name            = "StopEcs"
  document_type   = "Automation"
  document_format = "YAML"

  content = <<YAML
    description: ecs service stop automation runbook
    schemaVersion: '0.3'
    parameters:
      EcsClusterName:
        type: String
      EcsServiceName:
        type: String
    mainSteps:
      - name: ECS
        action: 'aws:executeAwsApi'
        inputs:
          Service: ecs
          Api: UpdateService
          cluster: '{{ EcsClusterName }}'
          service: '{{ EcsServiceName }}'
          desiredCount: 0
  YAML
}
