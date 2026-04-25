FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    tor \
    curl \
    wget \
    net-tools \
    openssh-server \
    && apt-get clean

# Tor config - SOCKS5 proxy 9050 port එකේ
RUN echo "SocksPort 0.0.0.0:9050" >> /etc/tor/torrc && \
    echo "RunAsDaemon 0" >> /etc/tor/torrc

# SSH enable කරන්න - Railway Web Terminal එකට
RUN mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

EXPOSE 9050 22

CMD service tor start && /usr/sbin/sshd -D
