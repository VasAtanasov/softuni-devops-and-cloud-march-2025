terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "docker" {
  host = "tcp://192.168.99.100:2375/"
}

resource "docker_image" "img-web" {
  name = "shekeriev/terraform-docker:latest"
}

resource "docker_container" "con-web" {
  name  = "site"
  image = docker_image.img-web.image_id
  ports {
    internal = "80"
    external = "80"
  }
}