mybgapp_db_image_repo     = "shekeriev/mybgapp-db"
mybgapp_web_image_repo    = "shekeriev/mybgapp-web"
docker_network_name       = "bgapp-net"
db_password               = "Password1"
web_http_port_external    = 80
web_http_port_internal    = 80
web_volume_container_path = "/var/www/html"
web_volume_host_path      = "/vagrant/terraform/task-1a/bgapp/web"