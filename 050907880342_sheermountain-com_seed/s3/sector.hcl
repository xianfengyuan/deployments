locals {
  sector = reverse(split("/", get_terragrunt_dir()))[0]
}
