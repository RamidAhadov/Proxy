job "kafka" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "kafka"

  group "kafka" {
    network {
      mode = "bridge"
      port "external" {
        to = 9094
      }
    }

    service {
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "zookeeper"
              local_bind_port  = 2181
            }
          }
        }
      }
      name = "kafka"
      port = "9092"
    }

    service {
      name = "kafka-external"
      port = "external"
      tags = [
          "traefik.enable=true",
          "traefik.tcp.routers.kafka-tcp-service.entrypoints=kafka",
          "traefik.tcp.routers.kafka-tcp-service.rule=HostSNI(`*`)"
      ]

      check {
        type = "tcp"
        port = "external"
        interval = "5s"
        timeout  = "2s"
      }
    }

      volume "kafka" {
      type            = "host"
      read_only       = false
      source          = "kafka"
    }


    task "kafka" {
      driver = "docker"
      config {
            image = "bitnami/kafka:3.5.0"
      }

      resources {
        memory     = 2000
        cpu        = 300
      }

      volume_mount {
        volume      = "kafka"
        destination = "/bitnami/kafka"
        read_only   = false
      }

      template {
        data        = <<EOH

       KAFKA_CFG_ADVERTISED_LISTENERS="INTERNAL://:9093,CLIENT://127.0.0.1:9092,EXTERNAL://{{ key "floating_ip" }}:9094"
               EOH
        destination = "local/file.env"
        env         = true
      }

      env {
        KAFKA_ENABLE_KRAFT                       = "false"
        KAFKA_BROKER_ID                          = 1
        KAFKA_ZOOKEEPER_CONNECT                  = "${NOMAD_UPSTREAM_ADDR_zookeeper}"
        KAFKA_INTER_BROKER_LISTENER_NAME         = "INTERNAL"
        KAFKA_CFG_LISTENERS                      = "INTERNAL://:9093,CLIENT://:9092,EXTERNAL://:9094"
        KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP = "INTERNAL:PLAINTEXT,CLIENT:PLAINTEXT,EXTERNAL:PLAINTEXT"
        ALLOW_PLAINTEXT_LISTENER                 = "yes"
        BITNAMI_DEBUG                            = "true"
      }
    }
  }
}