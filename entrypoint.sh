#!/bin/bash

CONFIG_FILE="/config/appsettings.json"
ENV_FILE="/config/env.sh"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file $CONFIG_FILE not found!"
    exit 1
fi

jq --arg ip "$BOOTSTRAP_SERVER" '.KafkaSettings.BootstrapServers = $ip' "$CONFIG_FILE" > temp.json && mv temp.json "$CONFIG_FILE"

exec /app/Proxy.DataService