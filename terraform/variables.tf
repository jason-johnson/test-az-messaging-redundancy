variable "name" {
  description = "base name for resources"
  default = "main"  
}

variable "salt" {
  description = "optional salt for use in the name"
  default     = ""
}
