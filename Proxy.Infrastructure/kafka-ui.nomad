job "kafka-ui" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "kafka"

  group "kafka-ui" {
    network {
      mode = "bridge"
      
      port "http" {
        to     = 8080
        static = 8080
      }
    }

    service {
      name = "kafka-ui"
      provider = "consul"
      port = "http"
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
    }

    task "kafka-ui" {
      driver = "docker"

      config {
        image = "provectuslabs/kafka-ui:latest"
        ports = ["http"]
      }

      resources {
        memory = 300
        cpu    = 100
      }

      env {
        SERVER_SERVLET_CONTEXT_PATH       = "/kafka-ui"
        KAFKA_CLUSTERS_0_NAME             = "local"
        KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS = "${NOMAD_UPSTREAM_ADDR_kafka}"
      }
    }
  }
}