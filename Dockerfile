FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    tor \
    curl \
    wget \
    net-tools \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Tor config - SOCKS5 proxy 0.0.0.0:9050
RUN echo "SocksPort 0.0.0.0:9050" > /etc/tor/torrc && \
    echo "RunAsDaemon 0" >> /etc/tor/torrc && \
    echo "DataDirectory /tmp/tor" >> /etc/tor/torrc

EXPOSE 9050

CMD tor
