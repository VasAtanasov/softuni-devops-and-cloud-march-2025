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
  name = lookup(var.v_image, var.mode)
}

resource "docker_container" "con-web" {
  name  = lookup(var.v_con_name, var.mode)
  image = docker_image.img-web.image_id
  ports {
    internal = lookup(var.v_int_port, var.mode)
    external = lookup(var.v_ext_port, var.mode)
  }
}
