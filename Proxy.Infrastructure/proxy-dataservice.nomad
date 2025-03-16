job "dataservice" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "application"

  group "applications" {
    network {
      mode = "bridge"

      port "http" {
        static = 8088
      }
    }

    service {
      name = "dataservice"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.dataservice.rule=PathPrefix(`/proxy`) && Host(`rahadov-lin01.simbrella.xyz`)",
        "traefik.http.services.dataservice.loadbalancer.server.port=8088",
        "traefik.http.services.dataservice.loadbalancer.server.scheme=http",
        "traefik.http.routers.dataservice.tls=true",
      ]
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
      name = "dataservice-connect"
      port = "http"
    }


    task "dataservice" {
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

      template {
        data = <<EOH
http://0.0.0.0:{{ env "NOMAD_PORT_http" }}
        EOH
        destination = "local/ApiControllerAddr.txt"
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
        cpu    = 200
        memory = 200
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