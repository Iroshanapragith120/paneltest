FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USERNAME=ubuntu
ENV PASSWORD=123456
ENV DISPLAY=:1

# 1. අවශ්‍ය හැමදේම එකපාර Install කරනවා
RUN apt-get update && apt-get install -y \
    openbox \
    xterm \
    tigervnc-standalone-server \
    tigervnc-tools \
    novnc \
    websockify \
    chromium-browser \
    wget \
    xz-utils \
    libxcb-xinerama0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-render-util0 \
    libxcb-xkb1 \
    libxkbcommon-x11-0 \
    libdbus-glib-1-2 \
    dbus-x11 \
    sudo \
    xfonts-base \
    --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. User හදනවා
RUN useradd -m -s /bin/bash $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    adduser $USERNAME sudo && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $USERNAME
WORKDIR /home/$USERNAME

# 3. VNC Password set කරනවා
RUN mkdir -p /home/$USERNAME/.vnc && \
    echo $PASSWORD | vncpasswd -f > /home/$USERNAME/.vnc/passwd && \
    chmod 600 /home/$USERNAME/.vnc/passwd

# 4. Tor Browser එක Install කරනවා
RUN wget https://www.torproject.org/dist/torbrowser/13.5.6/tor-browser-linux-x86_64-13.5.6.tar.xz -O /tmp/tor.tar.xz && \
    tar -xvf /tmp/tor.tar.xz -C /home/$USERNAME/ && \
    rm /tmp/tor.tar.xz && \
    mv /home/$USERNAME/tor-browser /home/$USERNAME/TorBrowser

# 5. Auto Start Script එක - මෙන්න මැජික් එක
RUN printf '#!/bin/bash\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
export XDG_RUNTIME_DIR=/tmp/runtime-$USER\n\
export DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/dbus-$USER\n\
mkdir -p $XDG_RUNTIME_DIR\n\
chmod 700 $XDG_RUNTIME_DIR\n\
dbus-daemon --session --address=$DBUS_SESSION_BUS_ADDRESS --fork\n\
openbox &\n\
sleep 3\n\
xterm &\n\
sleep 1\n\
chromium-browser --no-sandbox &\n\
sleep 2\n\
/home/ubuntu/TorBrowser/Browser/start-tor-browser --verbose &\n\
wait\n' > /home/$USERNAME/.vnc/xstartup && \
    chmod +x /home/$USERNAME/.vnc/xstartup

USER root
EXPOSE 6080

# 6. Final Run Command
CMD ["bash", "-c", "rm -f /tmp/.X1-lock /tmp/.X11-unix/X1; su - $USERNAME -c 'vncserver :1 -geometry 1280x720 -depth 24 -localhost no -SecurityTypes VncAuth' && websockify --web=/usr/share/novnc/ 6080 localhost:5901 && tail -f /dev/null"]
