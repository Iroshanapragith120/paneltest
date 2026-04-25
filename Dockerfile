FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USERNAME=ubuntu
ENV PASSWORD=123456
ENV DISPLAY=:1

RUN apt update && apt install -y \
    openbox \
    xterm \
    tigervnc-standalone-server \
    novnc \
    websockify \
    curl \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    xfonts-base \
    xfonts-75dpi \
    xfonts-100dpi \
    libnss3 \
    libxss1 \
    libasound2 \
    libgbm1 \
    fonts-liberation \
    --no-install-recommends \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Install Brave
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

# VNC xstartup - font path fix කරලා
RUN echo '#!/bin/bash\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexport XKL_XMODMAP_DISABLE=1\nopenbox-session &' > /home/$USERNAME/.vnc/xstartup && \
    chmod +x /home/$USERNAME/.vnc/xstartup

# Brave Tor auto start
RUN mkdir -p /home/$USERNAME/.config/openbox && \
    echo 'brave-browser --no-sandbox --disable-gpu --disable-dev-shm-usage --tor &' > /home/$USERNAME/.config/openbox/autostart && \
    echo 'xterm &' >> /home/$USERNAME/.config/openbox/autostart

USER root
EXPOSE 6080

CMD ["bash", "-c", "rm -f /tmp/.X1-lock /tmp/.X11-unix/X1; su - $USERNAME -c 'vncserver :1 -geometry 800x600 -depth 16 -SecurityTypes None -localhost no -fp /usr/share/fonts/X11/misc/' && websockify --web=/usr/share/novnc/ 6080 localhost:5901 && tail -f /home/$USERNAME/.vnc/*:1.log"]
