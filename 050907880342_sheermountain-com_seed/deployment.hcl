locals {
    account_id = "050907880342"
    domain = "sheermountain.com"
    mode = "state"
    name = "cloud-foundation"
    organization = "cloud-foundation"
    global_region = "us-west-2"
    bucket_domain   = replace(local.domain, ".", "-")
    bucket_prefix = "terraform"

    bucket_name = "${local.bucket_prefix}-${local.mode}-${local.bucket_domain}"

    config = {
        tfbucket = {
            no-version = {
                us-west-2 = {
                    s3-bucket = {
                        source_ref = "main"
                        bucket_name = local.bucket_name
                    }
                }
            }
        }
    }
}
