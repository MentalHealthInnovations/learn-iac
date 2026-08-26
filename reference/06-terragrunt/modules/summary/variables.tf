variable "pet_names" {
  description = "Pet name per environment, supplied by the caller from each environment's outputs."
  type        = map(string)
}

variable "output_dir" {
  description = "Directory the summary file is written to."
  type        = string
}
