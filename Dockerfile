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
    dbus-x11 \
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

# මෙන්න Fix එක - xstartup එක හරියට
RUN printf '#!/bin/bash\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexport XDG_RUNTIME_DIR=/tmp/runtime-$USER\nexport DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/dbus-$USER\nmkdir -p $XDG_RUNTIME_DIR\nchmod 700 $XDG_RUNTIME_DIR\ndbus-daemon --session --address=$DBUS_SESSION_BUS_ADDRESS --fork\nopenbox &\nfirefox &\nxterm &\nwait\n' > /home/$USERNAME/.vnc/xstartup && \
    chmod +x /home/$USERNAME/.vnc/xstartup

USER root
EXPOSE 6080

CMD ["bash", "-c", "rm -f /tmp/.X1-lock /tmp/.X11-unix/X1; su - $USERNAME -c 'vncserver :1 -geometry 800x600 -depth 16 -localhost no -SecurityTypes VncAuth' && websockify --web=/usr/share/novnc/ 6080 localhost:5901 && tail -f /dev/null"]
