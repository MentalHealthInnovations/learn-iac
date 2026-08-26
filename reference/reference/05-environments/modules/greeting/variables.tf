variable "environment" {
  description = "Name of the environment this instance represents."
  type        = string
}

variable "output_dir" {
  description = "Directory the file is written to. Supplied by the caller, because a module should not decide where its output lands."
  type        = string
}

variable "greeting" {
  description = "Opening word written into the file."
  type        = string
  default     = "Hello"
}

variable "pet_length" {
  description = "How many words in the generated pet name."
  type        = number
  default     = 2
}
