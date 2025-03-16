job "traefik" {
  datacenters = ["dc1"]
  namespace   = "traefik"
  type        = "system"

  group "traefik" {

    network {
      mode = "bridge"

      port "https" {
        static = 443
        to     = 443
      }
      port "admin" {
        static = 21002
        to     = 21002
      }
      port "kafka" {
        static = 9094
        to     = 9094
      }
      port "http" {
        static = 80
        to     = 80
      }
    }
    service {
      name = "traefik"
      port = "admin"
      connect {
        native = true
      }
      check {
        name     = "alive"
        type     = "http"
        port     = "admin"
        path     = "/ping"
        interval = "5s"
        timeout  = "2s"
      }
    }

    restart {
      attempts = 3
      delay    = "30s"
    }

    task "traefik" {
      driver = "docker"

      logs {
        max_files     = 3
        max_file_size = 10
      }

      resources {
        cpu    = 300
        memory = 100
      }

      config {
        image = "traefik:2.8.1"

        ports = ["admin", "https", "http"]

        volumes = [
          "local/traefik.yml:/etc/traefik/traefik.yml",
        ]
      }

      template {
        data        = "{{ key \"certificate.pem\" }}"
        destination = "local/certificate.pem"
      }
      template {
        data        = "{{ key \"key.pem\" }}"
        destination = "local/key.pem"
      }

      template {
        data        = <<EOH
api:
  insecure: true
  dashboard: true
ping: {}
entryPoints:
  websecure:
    address: ":443"
  traefik:
    address: ":21002"
  kafka:
    address: ":9094"   
  web:
    address: ":80" 
providers:
  consulcatalog:
    refreshInterval: 5s
    exposedByDefault: false
    endpoint:

      address: http://{{ key "floating_ip" }}:8500
      token: ""
    prefix: traefik
    connectAware: true
    connectByDefault: false
  file:
    filename: "local/traefik.yml"
tls:
  certificates:
    - certFile: local/certificate.pem
      keyFile: local/key.pem  
  options:
    default:
      minVersion: VersionTLS12
      cipherSuites:
      - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
      - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
      - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
      - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
      - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256
      - TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256
        # tls 1.3
      - TLS_AES_128_GCM_SHA256
      - TLS_AES_256_GCM_SHA384
      - TLS_CHACHA20_POLY1305_SHA256    
    mintls13:
      minVersion: VersionTLS13
http:
  routers:
    nomad:
      entryPoints:
        - websecure
      service: nomad
      rule: "Host(`nomad.rahadov-lin01.simbrella.xyz`)"
      tls: true
    consul:
      entryPoints:
        - websecure
      service: consul
      rule: "Host(`consul.rahadov-lin01.simbrella.xyz`)"
      tls: true
    traefik:
      entryPoints:
        - websecure
      service: api@internal
      rule: "Host(`traefik.rahadov-lin01.simbrella.xyz`)"
      tls: true                            
  services:

    nomad:
      loadBalancer:
        servers:
          - url: http://{{ key "floating_ip" }}:4646
    consul:
      loadBalancer:
        servers:
          - url: http://{{ key "floating_ip" }}:8500

log:
  level: DEBUG
accessLog: {}
metrics:
  prometheus:
    addRoutersLabels: true
    addServicesLabels: true
serversTransport:
  insecureSkipVerify: true    
                EOH
        destination = "local/traefik.yml"
      }
    }
  }
}