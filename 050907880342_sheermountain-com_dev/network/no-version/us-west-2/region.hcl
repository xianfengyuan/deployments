locals {
  deployment_vars = read_terragrunt_config(find_in_parent_folders("deployment.hcl"))
  global_region = local.deployment_vars.locals.global_region

  dir_region = reverse(split("/", get_terragrunt_dir()))[0]
  aws_region = local.dir_region == "global" ? local.global_region : local.dir_region
}
