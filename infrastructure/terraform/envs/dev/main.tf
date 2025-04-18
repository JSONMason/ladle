terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
}

variable "do_ssh_key_name" {
  type        = string
  description = "Name of the SSH key stored in DigitalOcean (lookup via data source)"
}

# Look up an existing SSH key in DigitalOcean by its name
data "digitalocean_ssh_key" "ladle" {
  name = var.do_ssh_key_name
}

module "ladle_vm" {
  source = "../../modules/vm"

  providers = {
    digitalocean = digitalocean
  }

  name     = "ladle-app"
  region   = "nyc3"
  size     = "s-1vcpu-1gb"
  image    = "docker-20-04"
  ssh_keys = [data.digitalocean_ssh_key.ladle.id]
  repo_url = "https://github.com/JSONMason/ladle.git"
}

output "ladle_public_ip" {
  value = module.ladle_vm.droplet_ip
}
