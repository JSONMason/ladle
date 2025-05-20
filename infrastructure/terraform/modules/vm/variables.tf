variable "name" {
  description = "Name of the VM/droplet"
  type        = string
}

variable "region" {
  description = "Region to deploy"
  type        = string
}

variable "size" {
  description = "Size of the VM"
  type        = string
}

variable "image" {
  description = "Base image or AMI"
  type        = string
}

variable "ssh_keys" {
  description = "List of SSH key IDs to attach"
  type        = list(string)
  default     = []
}

variable "repo_url" {
  description = "Git repository URL for Ladle"
  type        = string
}
