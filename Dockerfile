FROM ubuntu:22.04
WORKDIR /app

RUN apt-get update && apt-get install -y \
    libicu-dev \
    libssl-dev \
    librdkafka-dev \
    jq \
    dos2unix

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=0

COPY publish/Proxy.DataService .
COPY Proxy.DataService/Configuration/appsettings.json /etc/Proxy/Configuration/appsettings.json
COPY Proxy.DataService/NLog.config /etc/Proxy/Configuration/NLog.config
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /app/Proxy.DataService
RUN dos2unix /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]