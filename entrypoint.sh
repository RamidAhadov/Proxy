#!/bin/bash

CONFIG_FILE="/config/appsettings.json"
DEFAULT_CONFIG="/etc/Proxy/Configuration/appsettings.json"
ENV_FILE="/local/file.txt"

echo "==========================="
echo "🚀 Starting entrypoint.sh"
echo "==========================="

sleep 10000000

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ ERROR: $ENV_FILE not found! Exiting..."
    exit 1
fi

BOOTSTRAP_SERVER=$(cat "$ENV_FILE" | tr -d '[:space:]')

if [ -z "$BOOTSTRAP_SERVER" ]; then
    echo "❌ ERROR: BOOTSTRAP_SERVER is empty! Exiting..."
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    cp -v "$DEFAULT_CONFIG" "$CONFIG_FILE"
fi

jq --arg ip "$BOOTSTRAP_SERVER" '.KafkaSettings.BootstrapServers = $ip' "$CONFIG_FILE" > temp.json && mv temp.json "$CONFIG_FILE"

echo "DEBUG: Updated appsettings.json:"
cat "$CONFIG_FILE"

echo "==========================="
echo "✅ Configuration update complete!"
echo "🚀 Starting Proxy.DataService..."
echo "==========================="

exec /app/Proxy.DataService