terraform {
  source = "git::ssh://git@github.com/xianfengyuan/infrastructure.git//terraform/ec2?ref=${local.source_ref}"
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

dependency vpc {
  config_path = "../vpc"
}

inputs = merge(
  {
    subnet_id = element(dependency.vpc.outputs.public_subnets, 0)

    security_group_egress_rules = {
      vpc-endpoints = {
        description = "Allow outbound traffic to VPC endpoints"
        cidr_ipv4   = "0.0.0.0/0"
        from_port   = 443
      }
      postgres = {
        description = "Allow outbound traffic to db"
        cidr_ipv4   = "0.0.0.0/0"
        from_port   = 5432
      }
    }

    create_iam_instance_profile = true
    iam_role_description        = "IAM role for EC2 instance"
    iam_role_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  },
  try(local.module_vars, {})
)

include "root" {
  path = find_in_parent_folders()
}
