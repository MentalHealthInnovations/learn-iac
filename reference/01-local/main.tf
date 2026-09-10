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

resource "random_pet" "server" {
  length    = 3
  separator = "-"
}

resource "local_file" "greeting" {
  filename = "${path.module}/generated/hello.txt"
  content  = "Hello from ${random_pet.server.id}\n"
}
