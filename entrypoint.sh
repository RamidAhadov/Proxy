#!/bin/bash

CONFIG_FILE="/config/appsettings.json"
DEFAULT_CONFIG="/etc/Proxy/Configuration/appsettings.json"

if [ ! -f "$CONFIG_FILE" ]; then
    cp "$DEFAULT_CONFIG" "$CONFIG_FILE"
fi

jq --arg ip "$BOOTSTRAP_SERVER" '.KafkaSettings.BootstrapServers = $ip' "$CONFIG_FILE" > temp.json && mv temp.json "$CONFIG_FILE"

exec /app/Proxy.DataService