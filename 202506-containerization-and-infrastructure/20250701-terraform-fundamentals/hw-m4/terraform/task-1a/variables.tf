variable "mybgapp_db_image_repo" {
  description = "BGApp database image repo"
  type        = string
}

variable "mybgapp_db_image_tag" {
  description = "BGApp database image tag"
  type        = string
  default     = "latest"
}

variable "mybgapp_web_image_repo" {
  description = "BGApp web image repo"
  type        = string
}

variable "mybgapp_web_image_tag" {
  description = "BGApp web image tag"
  type        = string
  default     = "latest"
}

variable "docker_network_name" {
  description = "Name of Docker Network to use"
  type        = string
}

variable "db_password" {
  description = "Database Container Password"
  type        = string
}

variable "web_http_port_internal" {
  description = "Web container running port"
  type        = number
}

variable "web_http_port_external" {
  description = "Web container exposed port"
  type        = number
}

variable "web_volume_container_path" {
  description = "Web Container Volume - Container Path - Source"
  type        = string
}

variable "web_volume_host_path" {
  description = "Web Container Volume - Container Host Path"
  type        = string
}