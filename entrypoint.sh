#!/bin/bash

CONFIG_FILE="/config/appsettings.json"
DEFAULT_CONFIG="/etc/Proxy/Configuration/appsettings.json"
ENV_FILE="/config/env.sh"

echo "==========================="
echo "🚀 Starting entrypoint.sh"
echo "==========================="

# Wait for env.sh to be created by Nomad (max 10 seconds)
for i in {1..10000}; do
    if [ -f "$ENV_FILE" ]; then
        echo "✅ Found $ENV_FILE! Sourcing environment variables..."
        source "$ENV_FILE"
        break
    else
        echo "⏳ Waiting for $ENV_FILE to be created... ($i/10)"
        sleep 10
    fi
done

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ ERROR: $ENV_FILE not found! Exiting..."
    exit 1
fi

# Ensure appsettings.json exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "⚠️ $CONFIG_FILE not found! Copying from default location..."
    cp -v "$DEFAULT_CONFIG" "$CONFIG_FILE"
else
    echo "✅ $CONFIG_FILE already exists in /config/"
fi

# Ensure BOOTSTRAP_SERVER is set
if [ -z "$BOOTSTRAP_SERVER" ]; then
    echo "❌ ERROR: BOOTSTRAP_SERVER is empty! Exiting..."
    exit 1
else
    echo "✅ BOOTSTRAP_SERVER is set to: $BOOTSTRAP_SERVER"
fi

# Replace BootstrapServers dynamically
jq --arg ip "$BOOTSTRAP_SERVER" '.KafkaSettings.BootstrapServers = $ip' "$CONFIG_FILE" > temp.json && mv temp.json "$CONFIG_FILE"

echo "DEBUG: Updated appsettings.json:"
cat "$CONFIG_FILE"

echo "==========================="
echo "✅ Configuration update complete!"
echo "🚀 Starting Proxy.DataService..."
echo "==========================="

exec /app/Proxy.DataService
