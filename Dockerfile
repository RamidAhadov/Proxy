FROM ubuntu:22.04
WORKDIR /app

RUN apt-get update && apt-get install -y \
    libicu-dev \
    libssl-dev \
    librdkafka-dev \
    jq

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=0

COPY publish/Proxy.DataService .
COPY Proxy.DataService/Configuration/appsettings.json /etc/Proxy/Configuration/appsettings.json
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /app/Proxy.DataService
RUN chmod +x /entrypoint.sh && dos2unix /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]