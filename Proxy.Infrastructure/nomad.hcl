data_dir = "/opt/nomad/data"
bind_addr = "0.0.0.0"

server {
  enabled          = true
  bootstrap_expect = 1
  min_heartbeat_ttl = "30m"
  heartbeat_grace  = "5m"
}

client {
  enabled = true

  cni_path = "opt/cni/bin"
  cni_config_dir = "opt/cni/config"

  host_volume "shared" {
    path      = "/usr/app/storage/volumes/shared"
    read_only = false
  }

  host_volume "zookeeper" {
    path      = "/usr/app/storage/volumes/zookeeper"
    read_only = false
  }

  host_volume "kafka" {
    path      = "/usr/app/storage/volumes/kafka"
    read_only = false
  }

  host_volume "traefik" {
    path      = "/opt/nomad/data"
    read_only = false
  }

  host_volume "proxy" {
    path      = "/usr/app/storage/volumes/proxy-app"
    read_only = false
  }

  host_volume "logs" {
    path      = "/usr/app/storage/volumes/logs"
    read_only = false
  }
}

acl {
  enabled = true
}

consul {
  address = "127.0.0.1:8500"
  token = "c1e0dc66-18cb-eb04-8fe0-5568002a1fe0"
  server_service_name = "nomad"
  client_service_name = "nomad-client"
  auto_advertise = true
  server_auto_join = true
  client_auto_join = true
  enabled = true
}

plugin "docker" {
  host_volume = true
}

plugin "cni" {
    cni_path = "opt/cni/bin"
   cni_config_dir = "opt/cni/config"
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}