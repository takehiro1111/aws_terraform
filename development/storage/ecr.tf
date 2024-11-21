#####################################################
# ECR
#####################################################
#trivy:ignore:AVD-AWS-0033 // KMSでの暗号化は行わない。
resource "aws_ecr_repository" "development" {
  for_each = toset(var.ecr)

  name                 = each.value
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "development" {
  for_each   = toset(var.ecr)
  repository = each.value
  depends_on = [aws_ecr_repository.development]
  policy     = <<END
    {
      "Version": "2008-10-17",
      "Statement": [
        {
          "Sid": "AllowALL",
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.self.account_id}:root"
          },
          "Action": [
            "ecr:*"
          ]
        }
      ]
    }
  END
}

resource "aws_ecr_lifecycle_policy" "development" {
  for_each   = toset(var.ecr)
  repository = each.value
  depends_on = [aws_ecr_repository.development]
  policy     = <<END
    {
      "rules": [
        {
          "rulePriority": 1,
          "description": "Expire images older than 180 days",
          "selection": {
            "tagStatus": "untagged",
            "countType": "sinceImagePushed",
            "countUnit": "days",
            "countNumber": 180
          },
          "action": {
            "type": "expire"
          }
        },
        {
          "rulePriority": 2,
          "description": "Keep last 10 images",
          "selection": {
            "tagStatus": "any",
            "countType": "imageCountMoreThan",
            "countNumber": 10
          },
          "action": {
            "type": "expire"
          }
        }
      ]
    }
  END
}
