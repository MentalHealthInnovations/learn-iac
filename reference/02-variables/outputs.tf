output "pet_name" {
  description = "The generated pet name."
  value       = random_pet.server.id
}

output "files" {
  description = "Path of every file written, keyed by environment."
  value       = { for env, file in local_file.greeting : env => file.filename }
}
