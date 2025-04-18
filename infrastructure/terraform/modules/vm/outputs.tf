output "droplet_ip" {
  value       = digitalocean_droplet.this[0].ipv4_address
  description = "Public IP of the DigitalOcean droplet"
}
