terraform {
  source = "git::ssh://git@github.com/xianfengyuan/infrastructure.git//terraform/rds?ref=${local.source_ref}"
}

locals {
  module_name     = reverse(split("/", get_terragrunt_dir()))[0]
  deployment_vars = read_terragrunt_config(find_in_parent_folders("deployment.hcl"))

  sector_vars = read_terragrunt_config(find_in_parent_folders("sector.hcl"))
  sector      = local.sector_vars.locals.sector

  version_vars   = read_terragrunt_config(find_in_parent_folders("version.hcl"))
  version_string = local.version_vars.locals.version_string

  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region  = local.region_vars.locals.aws_region
  dir_region  = local.region_vars.locals.dir_region

  module_vars = local.deployment_vars.locals.config[local.sector][local.version_string][local.dir_region][local.module_name]
  source_ref  = local.module_vars.source_ref
}

dependency params_group {
  config_path = "../rds-params-group"
}

dependency vpc {
  config_path = "../../../../network/${local.version_string}/${local.dir_region}/vpc"
}

inputs = merge(
  {
    instance_class = "db.t3.small"
    owner_email = "ops@sheermountain.com"
    username = "simplebank"
    password = "simplebank123"
    db_parameter_group_name = dependency.params_group.outputs.db_parameter_group_name
    vpc_id = dependency.vpc.outputs.vpc_id
    db_subnets = dependency.vpc.outputs.database_subnets
  },
  try(local.module_vars, {})
)

include "root" {
  path = find_in_parent_folders()
}
