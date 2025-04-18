terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

resource "digitalocean_droplet" "this" {
  name     = var.name
  image    = var.image
  region   = var.region
  size     = var.size
  ssh_keys = var.ssh_keys

  # user_data bootstraps the droplet:
  user_data = <<-EOF
                #!/bin/bash
                apt-get update
                apt-get install -y docker.io docker-compose
                git clone ${var.repo_url} /opt/${var.name}
                cd /opt/${var.name}
                docker-compose --file infrastructure/docker/compose.yaml up --build -d
                EOF
}
