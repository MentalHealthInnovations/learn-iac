output "pet_name" {
  description = "The generated pet name."
  value       = random_pet.this.id
}

output "file_path" {
  description = "Where the file was written."
  value       = local_file.this.filename
}
