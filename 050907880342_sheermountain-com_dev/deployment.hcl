locals {
    account_id = "050907880342"
    domain = "sheermountain.com"
    mode = "dev"
    name = "sheermountain-dev"
    organization = "Sheer-Mountain-LLC"

    tf_state_bucket = "terraform-state-sheermountain-com"
    global_region = "us-west-2"
    bucket_prefix = ""
    bucket_domain   = replace(local.domain, ".", "-")

    zone_suffix = ["a", "b", "c"]
    network_cidr = "10.0.0.0/16"

    config = {
        network = {
            no-version = {
                us-west-2 = {
                    vpc = {
                        source_ref = "main"

                        name = "infranet"
                        cidr = local.network_cidr
                        azs = [for zone in local.zone_suffix: "us-west-2${zone}"]
                        private_subnets = [for k, v in local.zone_suffix : cidrsubnet(local.network_cidr, 4, k)]
                        public_subnets  = [for k, v in local.zone_suffix : cidrsubnet(local.network_cidr, 8, k + 48)]
                        intra_subnets   = [for k, v in local.zone_suffix : cidrsubnet(local.network_cidr, 8, k + 52)]
                        database_subnets   = [for k, v in local.zone_suffix : cidrsubnet(local.network_cidr, 8, k + 56)]
                    }
                    ec2 = {
                        source_ref = "xf_new"

                        name = "workstation"
                    }
                }
            }
        }
        database = {
            no-version = {
                us-west-2 = {
                    rds-params-group = {
                        source_ref = "main"

                        db_app_name = "simplebank"
                    }
                    rds = {
                        source_ref = "main"

                        db_app_name = "simplebank"
                    }
                }
            }
        }
    }
}
