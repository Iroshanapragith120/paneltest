FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USERNAME=ubuntu
ENV PASSWORD=123456

# අවශ්‍යම දේවල් විතරයි
RUN apt update && apt install -y \
    openbox \
    xterm \
    firefox-esr \
    tightvncserver \
    novnc \
    websockify \
    wget \
    --no-install-recommends \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Tor Browser latest auto install
RUN TBB_VERSION=$(wget -qO- https://aus1.torproject.org/torbrowser/update_3/release/Linux_x86_64-gcc3/x/en-US 2>/dev/null | grep -oP 'version="\K[^"]+' || echo "14.5.4") \
    && wget -q -O /tmp/tor.tar.xz https://www.torproject.org/dist/torbrowser/${TBB_VERSION}/tor-browser-linux-x86_64-${TBB_VERSION}.tar.xz \
    && tar -xf /tmp/tor.tar.xz -C /opt \
    && mv /opt/tor-browser /opt/tor \
    && rm /tmp/tor.tar.xz

RUN useradd -m -s /bin/bash $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    usermod -aG sudo $USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME

RUN mkdir -p /home/$USERNAME/.vnc && \
    echo $PASSWORD | vncpasswd -f > /home/$USERNAME/.vnc/passwd && \
    chmod 600 /home/$USERNAME/.vnc/passwd

# Openbox config - Firefox auto start
RUN mkdir -p /home/$USERNAME/.config/openbox && \
    echo 'firefox-esr &' > /home/$USERNAME/.config/openbox/autostart && \
    echo 'xterm &' >> /home/$USERNAME/.config/openbox/autostart

RUN echo '#!/bin/bash\nopenbox-session &' > /home/$USERNAME/.vnc/xstartup && \
    chmod +x /home/$USERNAME/.vnc/xstartup

USER root
EXPOSE 6080

CMD bash -c "su - $USERNAME -c 'vncserver :1 -geometry 800x600 -depth 16' && websockify --web=/usr/share/novnc/ 6080 localhost:5901 && tail -f /dev/null"
