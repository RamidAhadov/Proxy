FROM ubuntu:22.04
WORKDIR /app

RUN apt-get update && apt-get install -y \
    libicu-dev \
    libssl-dev \
    librdkafka-dev

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=0

COPY publish/Proxy.DataService .

RUN chmod +x /app/Proxy.DataService

ENTRYPOINT ["/app/Proxy.DataService"]
