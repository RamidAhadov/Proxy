#!/bin/bash
set -e

CONFIG="/etc/Proxy/Configuration/appsettings.json"
LOCAL_CONFIG="/local/appsettings.json"
BOOTSTRAP_SERVER_FILE="/local/BootstrapServerAddress.txt"
ASPNETCORE_URL_FILE="/local/ApiControllerAddr.txt"
SSL_PASSWORD_PATH="/local/sslpassword.txt"

for file in "$BOOTSTRAP_SERVER_FILE" "$ASPNETCORE_URL_FILE" "$SSL_PASSWORD_PATH"; do
    if [ ! -f "$file" ]; then
        echo "❌ ERROR: File $file not found!"
        exit 1
    fi
done

BOOTSTRAP_SERVER=$(tr -d '[:space:]' < "$BOOTSTRAP_SERVER_FILE")
ASPNETCORE_URL=$(tr -d '[:space:]' < "$ASPNETCORE_URL_FILE")
SSL_PASSWORD=$(tr -d '[:space:]' < "$SSL_PASSWORD_PATH")

jq --arg kafka "$BOOTSTRAP_SERVER" \
   --arg aspnet "$ASPNETCORE_URL" \
   --arg sslpass "$SSL_PASSWORD" \
   '.KafkaSettings.BootstrapServers = $kafka 
   | .ControllerSettings.AspNetUrl = $aspnet 
   | .ControllerSettings.CertPassword = $sslpass' "$CONFIG" > "$LOCAL_CONFIG"

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Failed to update appsettings.json with jq"
    exit 1
fi

echo "✅ Updated appsettings.json:"
cat "$LOCAL_CONFIG"

echo "======================================"
echo "🚀 Starting Proxy.DataService..."

exec /app/Proxy.DataService 2>&1
