job "proxy-dataservice" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "application"

  group "applications" {
    network {
      mode = "bridge"
    }

    service {
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "kafka"
              local_bind_port  = 9092
            }
          }
        }
      }
      name = "dataservice"
      port = "8088"
    }

    task "proxy-dataservice" {
      driver = "docker"

      config {
        image = "ramidahadov/proxy-app:latest"
      }

      template {
        data = <<EOH
{{ key "floating_ip" }}:9094
				EOH
        destination = "local/BootstrapServerAddress.txt"
        perms       = "0644"
        change_mode = "restart"
      }

      volume_mount {
        volume      = "proxy-config"
        destination = "/config"
      }

      volume_mount {
        volume      = "proxy-logs"
        destination = "/logs"
      }

      resources {
        cpu    = 500
        memory = 1000
      }
    }

    volume "proxy-config" {
      type      = "host"
      source    = "proxy"
      read_only = false
    }

    volume "proxy-logs" {
      type      = "host"
      source    = "logs"
      read_only = false
    }
  }
}