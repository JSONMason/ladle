output "droplet_ip" {
  value       = digitalocean_droplet.this.ipv4_address
  description = "Public IP of the DigitalOcean droplet"
}
