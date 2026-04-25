FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USERNAME=ubuntu
ENV PASSWORD=123456
ENV DISPLAY=:1

RUN apt-get update && apt-get install -y \
    openbox \
    xterm \
    tigervnc-standalone-server \
    tigervnc-tools \
    novnc \
    websockify \
    firefox \
    xfonts-base \
    --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    adduser $USERNAME sudo

USER $USERNAME
WORKDIR /home/$USERNAME

RUN mkdir -p /home/$USERNAME/.vnc && \
    echo $PASSWORD | vncpasswd -f > /home/$USERNAME/.vnc/passwd && \
    chmod 600 /home/$USERNAME/.vnc/passwd

RUN echo '#!/bin/bash\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nopenbox-session &' > /home/$USERNAME/.vnc/xstartup && \
    chmod +x /home/$USERNAME/.vnc/xstartup

RUN mkdir -p /home/$USERNAME/.config/openbox && \
    echo 'firefox &' > /home/$USERNAME/.config/openbox/autostart && \
    echo 'xterm &' >> /home/$USERNAME/.config/openbox/autostart

USER root
EXPOSE 6080

# Fix එක: SecurityTypes VncAuth දාලා localhost no දානවා
CMD ["bash", "-c", "rm -f /tmp/.X1-lock /tmp/.X11-unix/X1; su - $USERNAME -c 'vncserver :1 -geometry 800x600 -depth 16 -localhost no -SecurityTypes VncAuth' && websockify --web=/usr/share/novnc/ 6080 localhost:5901 && tail -f /dev/null"]
