resource "random_pet" "this" {
  length    = var.pet_length
  separator = "-"
}

resource "local_file" "this" {
  filename = "${var.output_dir}/${var.environment}.txt"
  content  = "${var.greeting} from ${random_pet.this.id}, running in ${var.environment}\n"
}
