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

module "dev" {
  source = "./modules/greeting"

  environment = "dev"
  output_dir  = "${path.root}/generated"
}

module "prod" {
  source = "./modules/greeting"

  environment = "prod"
  output_dir  = "${path.root}/generated"
  greeting    = "Good morning"
  pet_length  = 3
}
