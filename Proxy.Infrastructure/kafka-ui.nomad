job "kafka-ui" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "kafka"

  group "kafka-ui" {
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
      name = "kafka-ui"
      port = "8080"
      tags = [
        "traefik.enable=true",
        "traefik.consulCatalog.connect=true",
        "traefik.http.routers.kafka-ui.rule=PathPrefix(`/kafka-ui`) && Host(`rahadov-lin01.simbrella.xyz`)",
        "traefik.http.middlewares.kafka-ui-auth.basicauth.users=admin:$2y$05$an8Jyn.18ETYJWC/BD6B4eX0BdbCmMyMXsF8YApG8dPFL8GuXarXO",
        "traefik.http.routers.kafka-ui.middlewares=kafka-ui-auth",
        "traefik.http.routers.kafka-ui.tls=true"
      ]
    }

    task "kafka" {
      driver = "docker"
      config {
        image = "provectuslabs/kafka-ui:latest"
      }

      resources {
        memory     = 300
        cpu        = 100
      }
      env {
        SERVER_SERVLET_CONTEXT_PATH       = "/kafka-ui"
        KAFKA_CLUSTERS_0_NAME             = "local"
        KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS = "${NOMAD_UPSTREAM_ADDR_kafka}"
      }
    }
  }
}