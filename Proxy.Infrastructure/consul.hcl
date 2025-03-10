client_addr = "0.0.0.0"
bind_addr = "{{ GetInterfaceIP \"ens192\" }}"

data_dir = "/opt/consul/data"

bootstrap_expect = 1
acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
}

ui_config {
  enabled = true
}

server = true
retry_join = ["172.18.184.156"]

ports {
  grpc = 8502
}

connect {
  enabled = true
}