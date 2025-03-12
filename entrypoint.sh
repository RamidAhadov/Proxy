#!/bin/bash
set -e

CONFIG="/etc/Proxy/Configuration/appsettings.json"
LOCAL_CONFIG="/local/appsettings.json"
BOOTSTRAP_SERVER_FILE="/local/BootstrapServerAddress.txt"
ASPNETCORE_ADDR_FILE="/local/ApiControllerAddress.txt"

for FILE in "$BOOTSTRAP_SERVER_FILE" "$ASPNETCORE_ADDR_FILE"; do
    if [ ! -f "$FILE" ]; then
        echo "❌ ERROR: Required file $FILE not found!"
        exit 1
    fi
done

BOOTSTRAP_SERVER=$(<"$BOOTSTRAP_SERVER_FILE" tr -d '[:space:]')
ASPNETCORE_ADDRESS=$(<"$ASPNETCORE_ADDR_FILE" tr -d '[:space:]')

if [[ -z "$BOOTSTRAP_SERVER" || -z "$ASPNETCORE_ADDRESS" ]]; then
    echo "❌ ERROR: Missing environment variables!"
    exit 1
fi

# Update configuration
jq \
  --arg kafka "$BOOTSTRAP_SERVER" \
  --arg aspnet "$ASPNETCORE_ADDRESS" \
  '.KafkaSettings.BootstrapServers = $ip | .ControllerSettings.Url = $aspnet' "$CONFIG" \
  > temp.json && mv -f temp.json "$CONFIG"

# Ensure configuration copied
cp -fv "$CONFIG" "$LOCAL_CONFIG"

echo "===================================="
echo "✅ Configuration updated and applied:"
echo "- Kafka Bootstrap Server: $BOOTSTRAP_SERVER"
echo "- ASP.NET Core URL: $ASPNETCORE_ADDRESS"
echo "====================================="
echo "🚀 Starting Proxy.DataService..."

exec /app/Proxy.DataService