FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USERNAME=ubuntu
ENV PASSWORD=123456
ENV DISPLAY=:1

# 1. හැමදේම Install කරනවා - torbrowser-launcher පාවිච්චි කරනවා wget වෙනුවට
RUN apt-get update && apt-get install -y \
    openbox \
    xterm \
    tigervnc-standalone-server \
    tigervnc-tools \
    novnc \
    websockify \
    chromium-browser \
    torbrowser-launcher \
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
    software-properties-common \
    --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. User හදනවා + sudo No Password
RUN useradd -m -s /bin/bash $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    adduser $USERNAME sudo && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $USERNAME
WORKDIR /home/$USERNAME

# 3. VNC Password
RUN mkdir -p /home/$USERNAME/.vnc && \
    echo $PASSWORD | vncpasswd -f > /home/$USERNAME/.vnc/passwd && \
    chmod 600 /home/$USERNAME/.vnc/passwd

# 4. Tor Browser එක Auto Install වෙන්න Settings හදනවා
RUN mkdir -p /home/$USERNAME/.config/torbrowser && \
    echo 'settings: { "download_over_tor": false, "install_method": "direct" }' > /home/$USERNAME/.config/torbrowser/settings.json

# 5. Auto Start Script - Terminal + Chromium + Tor 3ම Open කරනවා
RUN printf '#!/bin/bash\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
export XDG_RUNTIME_DIR=/tmp/runtime-$USER\n\
export DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/dbus-$USER\n\
export QT_X11_NO_MITSHM=1\n\
mkdir -p $XDG_RUNTIME_DIR\n\
chmod 700 $XDG_RUNTIME_DIR\n\
dbus-daemon --session --address=$DBUS_SESSION_BUS_ADDRESS --fork\n\
openbox &\n\
sleep 3\n\
xterm &\n\
sleep 1\n\
chromium-browser --no-sandbox --start-maximized &\n\
sleep 3\n\
torbrowser-launcher &\n\
wait\n' > /home/$USERNAME/.vnc/xstartup && \
    chmod +x /home/$USERNAME/.vnc/xstartup

USER root
EXPOSE 6080

CMD ["bash", "-c", "rm -f /tmp/.X1-lock /tmp/.X11-unix/X1; su - $USERNAME -c 'vncserver :1 -geometry 1280x720 -depth 24 -localhost no -SecurityTypes VncAuth' && websockify --web=/usr/share/novnc/ 6080 localhost:5901 && tail -f /dev/null"]
