#!/bin/bash
set -e

CONFIG="/etc/Proxy/Configuration/appsettings.json"
LOCAL_CONFIG="/local/appsettings.json"
BOOTSTRAP_SERVER_FILE="/local/BootstrapServerAddress.txt"
ASPNETCORE_URL_FILE="/local/ApiControllerAddress.txt"

for file in "$BOOTSTRAP_SERVER_FILE" "$ASPNETCORE_URL_FILE"; do
    if [ ! -f "$file" ]; then
        echo "❌ ERROR: File $file not found!"
        exit 1
    fi
done

BOOTSTRAP_SERVER=$(<"$BOOTSTRAP_SERVER_FILE" tr -d '[:space:]')
ASPNETCORE_URL=$(<"$ASPNETCORE_URL_FILE" tr -d '[:space:]')

jq \
  --arg kafka "$BOOTSTRAP_SERVER" \
  --arg aspnet "$ASPNETCORE_URL" \
  '.KafkaSettings.BootstrapServers = $kafka | .ControllerSettings.Url = $aspnet' \
  "$CONFIG" > "$LOCAL_CONFIG"

echo "✅ Updated appsettings.json:"
cat "$LOCAL_CONFIG"

echo "======================================"
echo "🚀 Starting Proxy.DataService..."

exec /app/Proxy.DataService