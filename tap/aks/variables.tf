variable "location" {
  type        = string
  description = "The Azure location where resources are created"
  default     = "francecentral"
}

variable "prefix" {
  type        = string
  description = "The prefix used for resources"
  default     = "tanzu"
}

variable "env" {
  type        = string
  description = "The target environment"
  default     = "tap"
}
