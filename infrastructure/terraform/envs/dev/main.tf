terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "Ladle"
    workspaces {
      name = "ladle"
    }
  }

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
}

variable "do_ssh_key_names" {
  type        = list(string)
  description = "List of SSH key names in DO to authorize"
  default     = ["macbook", "cicd"]
}

# Lookup each key by name
data "digitalocean_ssh_key" "ladle_keys" {
  for_each = toset(var.do_ssh_key_names)
  name     = each.value
}

module "ladle_vm" {
  source = "../../modules/vm"

  providers = {
    digitalocean = digitalocean
  }

  name   = "ladle-app"
  image  = "docker-20-04"
  region = "nyc3"
  size   = "s-1vcpu-1gb"
  ssh_keys = [
    for key in data.digitalocean_ssh_key.ladle_keys :
    key.fingerprint
  ]
  repo_url = "https://github.com/JSONMason/ladle.git"
}

output "ladle_public_ip" {
  value = module.ladle_vm.droplet_ip
}
