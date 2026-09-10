terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

locals {
  output_dir = "${path.module}/generated"
}

resource "random_pet" "server" {
  length    = var.pet_length
  separator = "-"
}

resource "local_file" "greeting" {
  for_each = var.environments

  filename = "${local.output_dir}/${each.key}.txt"
  content  = "${var.greeting} from ${random_pet.server.id}, running in ${each.key}\n"
}
