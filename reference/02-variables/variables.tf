variable "pet_length" {
  description = "How many words in the generated pet name."
  type        = number
  default     = 2

  validation {
    condition     = var.pet_length >= 1 && var.pet_length <= 4
    error_message = "pet_length must be between 1 and 4."
  }
}

variable "greeting" {
  description = "Opening word written into each generated file."
  type        = string
  default     = "Hello"
}

variable "environments" {
  description = "One file is written for each name in this set."
  type        = set(string)
  default     = ["dev", "staging", "prod"]
}
