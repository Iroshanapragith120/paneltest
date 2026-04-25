FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USERNAME=ubuntu
ENV PASSWORD=123456

RUN apt update && apt install -y \
    xfce4 xfce4-goodies \
    tightvncserver \
    dbus-x11 \
    wget \
    novnc \
    websockify \
    curl \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    libnss3 \
    libxss1 \
    libasound2 \
    && apt clean

# Install Brave Browser
RUN curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list \
    && apt update \
    && apt install -y brave-browser

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

# Desktop shortcut for Brave with Tor
RUN mkdir -p /home/$USERNAME/Desktop && \
    echo '[Desktop Entry]\nVersion=1.0\nType=Application\nName=Brave Tor\nComment=Brave with Tor\nExec=brave-browser --no-sandbox --tor\nIcon=brave-browser\nTerminal=false' > /home/$USERNAME/Desktop/Brave-Tor.desktop && \
    echo '[Desktop Entry]\nVersion=1.0\nType=Application\nName=Brave Normal\nComment=Brave Normal\nExec=brave-browser --no-sandbox\nIcon=brave-browser\nTerminal=false' > /home/$USERNAME/Desktop/Brave.desktop && \
    chmod +x /home/$USERNAME/Desktop/*.desktop

USER root
EXPOSE 6080

CMD bash -c "su - $USERNAME -c 'vncserver :1 -geometry 1024x768 -depth 24' && websockify --web=/usr/share/novnc/ 6080 localhost:5901 && tail -f /dev/null"
