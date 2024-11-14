locals {
  env_yml        = yamldecode(file("../locals.yml"))
  repository_yml = yamldecode(file("../locals.yml"))

  // CloudFrontのロギング用バケットのPrefix設定
  processing            = replace(module.value.cdn_takehiro1111_com, ".", "_")
  logging_config_prefix = replace(local.processing, "-", "_")

  // ライフサイクルポリシーをdynamicブロックで再利用
  lifecycle_configuration = [
    {
      id     = local.logging_config_prefix
      status = "Enabled"
      prefix = local.logging_config_prefix

      transitions = [
        { days = 30, storage_class = "STANDARD_IA" },
        { days = 180, storage_class = "GLACIER" },
        { days = 365, storage_class = "DEEP_ARCHIVE" }
      ]

      nonself_version_transition = {
        newer_nonself_versions = 1
        nonself_days           = 30
        storage_class          = "DEEP_ARCHIVE"
      }
    }
  ]
}
