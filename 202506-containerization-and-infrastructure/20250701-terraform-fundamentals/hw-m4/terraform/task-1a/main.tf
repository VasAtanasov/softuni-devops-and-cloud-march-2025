terraform {
  required_version = ">= 1.12"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }
  }
}

provider "docker" {}

# To be able to update an image dynamically when the sha256 sum changes,
# we need to use it in combination with docker_registry_image.

# DB Image
data "docker_registry_image" "mybgapp-db" {
  name = "shekeriev/mybgapp-db:latest"
}

resource "docker_image" "mybgapp-db" {
  name          = data.docker_registry_image.mybgapp-db.name
  pull_triggers = [data.docker_registry_image.mybgapp-db.sha256_digest]
}

# WEB Image
data "docker_registry_image" "mybgapp-web" {
  name = "shekeriev/mybgapp-web:latest"
}

resource "docker_image" "mybgapp-web" {
  name          = data.docker_registry_image.mybgapp-web.name
  pull_triggers = [data.docker_registry_image.mybgapp-web.sha256_digest]
}

# Network
resource "docker_network" "bgapp_net" {
  name = "bgapp_net"
}

# DB Container
resource "docker_container" "db" {
  name  = "db"
  image = docker_image.mybgapp-db.name

  networks_advanced {
    name = docker_network.bgapp_net.name
  }

  ports {
    internal = 3306
    external = 3306
  }

  env = [
    "MYSQL_ROOT_PASSWORD=Password1"
  ]
}

# Web Container
resource "docker_container" "web" {
  name  = "web"
  image = docker_image.mybgapp-web.name

  networks_advanced {
    name = docker_network.bgapp_net.name
  }

  ports {
    internal = 80
    external = 80
  }

  volumes {
    container_path = "/var/www/html"
    host_path      = "${path.cwd}/bgapp/web"
    read_only      = true
  }

  depends_on = [docker_container.db]
}
