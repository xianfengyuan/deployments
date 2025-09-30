locals {
    deployment_vars = read_terragrunt_config(find_in_parent_folders("deployment.hcl"))
    account_id      = local.deployment_vars.locals.account_id
    sector_vars = read_terragrunt_config(find_in_parent_folders("sector.hcl"))
    version_vars = read_terragrunt_config(find_in_parent_folders("version.hcl"))
    region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
    aws_region = local.region_vars.locals.aws_region

    deployment_tf_state_bucket = local.deployment_vars.locals.bucket_name
}

# Use local for state for seed deployment, later pushed to remote
remote_state {
    backend = "s3"
    generate = {
        path = "backend.tf"
        if_exists = "overwrite_terragrunt"
    }
    config = {
        bucket = local.deployment_tf_state_bucket
        key = "${path_relative_to_include()}/terraform.tfstate"
        encrypt = true
        region = "us-west-2"
        dynamodb_table = "${local.deployment_tf_state_bucket}-lock"
    }
}

terraform_version_constraint = "=1.12.2"
terragrunt_version_constraint = "=0.72.6"

generate "provider" {
    path = "provider.tf"
    if_exists = "overwrite_terragrunt"
    contents = <<EOF
provider "aws" {
    region = "${local.aws_region}"
    allowed_account_ids = ["${local.account_id}"]
}
EOF
}

inputs = merge(
    local.deployment_vars.locals,
    local.sector_vars.locals,
    local.version_vars.locals,
    local.region_vars.locals
)
