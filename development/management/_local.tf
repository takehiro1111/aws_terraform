/* 
 * Common
 */
locals {
  env_yml        = yamldecode(file("../locals.yml"))
  repository_yml = yamldecode(file("../locals.yml"))
}
