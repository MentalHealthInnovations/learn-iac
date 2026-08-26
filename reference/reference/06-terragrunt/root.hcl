# Shared by every unit below. Included once per unit, written once here.

remote_state {
  backend = "local"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    path = "${get_parent_terragrunt_dir()}/state/${path_relative_to_include()}/terraform.tfstate"
  }
}

inputs = {
  output_dir = "${get_parent_terragrunt_dir()}/generated"
}
