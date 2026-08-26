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

module "greeting" {
  source = "../modules/greeting"

  environment = "staging"
  output_dir  = "${path.root}/generated"
  greeting    = "Hello"
  pet_length  = 2
}

output "pet_name" {
  value = module.greeting.pet_name
}
