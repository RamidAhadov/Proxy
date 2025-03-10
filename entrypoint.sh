#!/bin/bash

CONFIG_FILE="/config/appsettings.json"
DEFAULT_CONFIG="/etc/Proxy/Configuration/appsettings.json"
ENV_FILE="/config/env.sh"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Copying default appsettings.json to /config/..."
    cp -v "$DEFAULT_CONFIG" "$CONFIG_FILE"
else
    echo "appsettings.json already exists in /config/"
fi

jq --arg ip "$BOOTSTRAP_SERVER" '.KafkaSettings.BootstrapServers = $ip' "$CONFIG_FILE" > temp.json && mv temp.json "$CONFIG_FILE"

exec /app/Proxy.DataService
