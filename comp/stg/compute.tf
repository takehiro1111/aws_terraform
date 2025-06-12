##########################################################
# EC2
##########################################################
#踏み台サーバ-------------------------
# module "bastion" {
#   source                 = "../../modules/ec2/bastion"
#   env                    = local.env
#   vpc_id                 = module.vpc_comp_stg.vpc_id
#   subnet_id              = module.vpc_comp_stg.private_subnets[0]
#   create_common_resource = true

#   iam_role_inlinepolicy_resources = [
#     "${module.s3_bastion_tmp.s3_bucket_arn}/*"
#   ]

#   ## 一時的にEBSを利用する場合はtrueにする
#   create_tmp_ebs_resource = false
# }
