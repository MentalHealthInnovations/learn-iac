include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules/summary"
}

# Each dependency reads another unit's outputs, and creates an ordering:
# run --all applies the three greeting units before this one.
#
# The mocks let this unit plan before those units have ever been applied, when
# there are no real outputs to read. Restricting them to plan and validate is
# what keeps a fake value out of an apply, and the values are deliberately
# self-describing so they are obvious in a plan a reviewer reads.

dependency "dev" {
  config_path                             = "../dev"
  mock_outputs_allowed_terraform_commands = ["validate", "init", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"

  mock_outputs = {
    pet_name = "MOCK-dev-not-yet-applied"
  }
}

dependency "staging" {
  config_path                             = "../staging"
  mock_outputs_allowed_terraform_commands = ["validate", "init", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"

  mock_outputs = {
    pet_name = "MOCK-staging-not-yet-applied"
  }
}

dependency "prod" {
  config_path                             = "../prod"
  mock_outputs_allowed_terraform_commands = ["validate", "init", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"

  mock_outputs = {
    pet_name = "MOCK-prod-not-yet-applied"
  }
}

inputs = {
  pet_names = {
    dev     = dependency.dev.outputs.pet_name
    staging = dependency.staging.outputs.pet_name
    prod    = dependency.prod.outputs.pet_name
  }
}
