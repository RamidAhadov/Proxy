#!/bin/bash

CONFIG="/etc/Proxy/Configuration/appsettings.json"
LOCAL_CONFIG="/local/appsettings.json"
ENV_FILE="/local/BootstrapServerAddress.txt"

echo "==========================="
echo "🚀 Starting entrypoint.sh"
echo "==========================="

sleep 5

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ ERROR: $ENV_FILE not found! Exiting..."
    exit 1
fi

BOOTSTRAP_SERVER=$(cat "$ENV_FILE" | tr -d '[:space:]')

if [ -z "$BOOTSTRAP_SERVER" ]; then
    echo "❌ ERROR: BOOTSTRAP_SERVER is empty! Exiting..."
    exit 1
fi

jq --arg ip "$BOOTSTRAP_SERVER" '.KafkaSettings.BootstrapServers = $ip' "$CONFIG" > temp.json && mv temp.json "$CONFIG"

echo "DEBUG: Updated appsettings.json:"
cat "$CONFIG"

# Copy the updated config to /local before starting the service
cp -v "$CONFIG" "$LOCAL_CONFIG"

echo "==========================="
echo "✅ Configuration copied to /local!"
echo "🚀 Starting Proxy.DataService..."
echo "==========================="

exec /app/Proxy.DataService