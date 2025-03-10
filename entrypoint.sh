#!/bin/bash

CONFIG_FILE="/config/appsettings.json"
DEFAULT_CONFIG="/etc/Proxy/Configuration/appsettings.json"
ENV_FILE="/config/env.sh"

echo "==========================="
echo "🚀 Starting entrypoint.sh"
echo "==========================="

# Check if env.sh exists and source it
echo "🔍 Checking if $ENV_FILE exists..."
if [ -f "$ENV_FILE" ]; then
    echo "✅ Found $ENV_FILE. Sourcing environment variables..."
    source "$ENV_FILE"
    echo "🌍 BOOTSTRAP_SERVER is set to: $BOOTSTRAP_SERVER"
else
    echo "❌ ERROR: $ENV_FILE not found! BOOTSTRAP_SERVER may not be set."
fi

# Ensure appsettings.json exists in /config/
echo "🔍 Checking if $CONFIG_FILE exists in /config/..."
if [ ! -f "$CONFIG_FILE" ]; then
    echo "⚠️ $CONFIG_FILE does NOT exist! Copying from default location..."
    cp -v "$DEFAULT_CONFIG" "$CONFIG_FILE"
    echo "✅ Successfully copied $DEFAULT_CONFIG to /config/"
else
    echo "✅ $CONFIG_FILE already exists in /config/"
fi

# Verify BOOTSTRAP_SERVER is set before modifying appsettings.json
echo "🔍 Verifying BOOTSTRAP_SERVER..."
if [ -z "$BOOTSTRAP_SERVER" ]; then
    echo "❌ ERROR: BOOTSTRAP_SERVER is empty! Exiting..."
    exit 1
else
    echo "✅ BOOTSTRAP_SERVER is correctly set to: $BOOTSTRAP_SERVER"
fi

# Modify appsettings.json to inject BOOTSTRAP_SERVER
echo "🔄 Updating BootstrapServers in appsettings.json..."
jq --arg ip "$BOOTSTRAP_SERVER" '.KafkaSettings.BootstrapServers = $ip' "$CONFIG_FILE" > temp.json && mv temp.json "$CONFIG_FILE"

# Verify the changes in appsettings.json
echo "🔍 Verifying updated appsettings.json..."
cat "$CONFIG_FILE"

echo "==========================="
echo "✅ Configuration update complete!"
echo "🚀 Starting Proxy.DataService..."
echo "==========================="

exec /app/Proxy.DataService