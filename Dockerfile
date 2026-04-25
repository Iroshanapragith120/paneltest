FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USERNAME=ubuntu
ENV PASSWORD=123456

RUN apt update && apt install -y \
    xfce4 xfce4-goodies \
    tightvncserver \
    dbus-x11 \
    x11-utils \
    xfonts-base \
    firefox \
    wget \
    novnc \
    websockify \
    libdbus-glib-1-2 \
    libgtk-3-0 \
    libx11-xcb1 \
    libxt6 \
    libxcomposite1 \
    libasound2 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libnss3 \
    && apt clean

# Install Tor Browser - Auto latest version
RUN TBB_VERSION=$(wget -qO- https://aus1.torproject.org/torbrowser/update_3/release/Linux_x86_64-gcc3/x/en-US | grep -oP 'version="\K[^"]+') \
    && wget -O /tmp/tor.tar.xz https://www.torproject.org/dist/torbrowser/${TBB_VERSION}/tor-browser-linux-x86_64-${TBB_VERSION}.tar.xz \
    && tar -xf /tmp/tor.tar.xz -C /opt \
    && mv /opt/tor-browser /opt/tor \
    && ln -s /opt/tor/Browser/start-tor-browser /usr/local/bin/tor-browser \
    && rm /tmp/tor.tar.xz

RUN useradd -m -s /bin/bash $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    usermod -aG sudo $USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME

RUN mkdir -p /home/$USERNAME/.vnc && \
    echo $PASSWORD | vncpasswd -f > /home/$USERNAME/.vnc/passwd && \
    chmod 600 /home/$USERNAME/.vnc/passwd

RUN echo '#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &' > /home/$USERNAME/.vnc/xstartup && \
    chmod +x /home/$USERNAME/.vnc/xstartup

# Desktop shortcuts
RUN mkdir -p /home/$USERNAME/Desktop && \
    echo '[Desktop Entry]\nVersion=1.0\nType=Application\nName=Tor Browser\nComment=Browse with Tor\nExec=/opt/tor/Browser/start-tor-browser --detach\nIcon=/opt/tor/Browser/browser/chrome/icons/default128.png\nTerminal=false' > /home/$USERNAME/Desktop/Tor.desktop && \
    echo '[Desktop Entry]\nVersion=1.0\nType=Application\nName=Firefox\nExec=firefox\nIcon=firefox\nTerminal=false' > /home/$USERNAME/Desktop/Firefox.desktop && \
    chmod +x /home/$USERNAME/Desktop/*.desktop

USER root
EXPOSE 6080

CMD bash -c "su - $USERNAME -c 'vncserver :1 -geometry 1024x768 -depth 24' && websockify --web=/usr/share/novnc/ 6080 localhost:5901 && tail -f /dev/null"
