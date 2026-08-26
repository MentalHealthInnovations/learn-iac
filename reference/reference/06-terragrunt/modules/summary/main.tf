resource "local_file" "this" {
  filename = "${var.output_dir}/summary.txt"
  content  = "${join("\n", [for env, name in var.pet_names : "${env}: ${name}"])}\n"
}
