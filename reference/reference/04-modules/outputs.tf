output "dev_pet" {
  description = "Pet name generated for dev."
  value       = module.dev.pet_name
}

output "prod_pet" {
  description = "Pet name generated for prod."
  value       = module.prod.pet_name
}
