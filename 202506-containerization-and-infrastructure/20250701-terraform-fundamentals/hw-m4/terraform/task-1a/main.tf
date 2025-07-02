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
# we need to use docker_image in combination with docker_registry_image.

# DB Image
data "docker_registry_image" "mybgapp_db" {
  name = "${var.mybgapp_db_image_repo}:${var.mybgapp_db_image_tag}"
}

resource "docker_image" "mybgapp_db" {
  name = data.docker_registry_image.mybgapp_db.name
  pull_triggers = [data.docker_registry_image.mybgapp_db.sha256_digest]
}

# WEB Image
data "docker_registry_image" "mybgapp_web" {
  name = "${var.mybgapp_web_image_repo}:${var.mybgapp_web_image_tag}"
}

resource "docker_image" "mybgapp_web" {
  name = data.docker_registry_image.mybgapp_web.name
  pull_triggers = [data.docker_registry_image.mybgapp_web.sha256_digest]
}

# Network
resource "docker_network" "bgapp_net" {
  name = var.docker_network_name
}

# DB Container
resource "docker_container" "db" {
  name  = "db"
  image = docker_image.mybgapp_db.name

  networks_advanced {
    name = docker_network.bgapp_net.name
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${var.db_password}"
  ]
}

# Web Container
resource "docker_container" "web" {
  name  = "web"
  image = docker_image.mybgapp_web.name

  networks_advanced {
    name = docker_network.bgapp_net.name
  }

  ports {
    internal = var.web_http_port_internal
    external = var.web_http_port_external
  }

  volumes {
    host_path      = var.web_volume_host_path
    container_path = var.web_volume_container_path
    read_only      = true
  }

  depends_on = [
    docker_container.db
  ]
}
