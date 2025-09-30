locals {
  version_string = reverse(split("/", get_terragrunt_dir()))[0]
}
