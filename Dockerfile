FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USERNAME=ubuntu
ENV PASSWORD=123456

# Minimal + Brave install
RUN apt update && apt install -y \
    openbox \
    xterm \
    tightvncserver \
    novnc \
    websockify \
    curl \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    --no-install-recommends \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Install Brave Browser
RUN curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list \
    && apt update \
    && apt install -y brave-browser \
    && apt clean

RUN useradd -m -s /bin/bash $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    usermod -aG sudo $USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME

RUN mkdir -p /home/$USERNAME/.vnc && \
    echo $PASSWORD | vncpasswd -f > /home/$USERNAME/.vnc/passwd && \
    chmod 600 /home/$USERNAME/.vnc/passwd

# Auto start Brave with Tor mode
RUN mkdir -p /home/$USERNAME/.config/openbox && \
    echo 'brave-browser --no-sandbox --tor &' > /home/$USERNAME/.config/openbox/autostart && \
    echo 'xterm &' >> /home/$USERNAME/.config/openbox/autostart

RUN echo '#!/bin/bash\nopenbox-session &' > /home/$USERNAME/.vnc/xstartup && \
    chmod +x /home/$USERNAME/.vnc/xstartup

USER root
EXPOSE 6080

CMD bash -c "su - $USERNAME -c 'vncserver :1 -geometry 800x600 -depth 16' && websockify --web=/usr/share/novnc/ 6080 localhost:5901 && tail -f /dev/null"
