FROM debian:11

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root

# Ngrok සහ Desktop එක ඉන්ස්ටෝල් කිරීම
RUN apt update && apt install -y \
    xfce4 xfce4-terminal tightvncserver \
    wget curl ca-certificates firefox-esr \
    && wget https://bin.equinox.io/c/b342Pmq6Ez7/ngrok-v3-stable-linux-amd64.tgz \
    && tar -xvzf ngrok-v3-stable-linux-amd64.tgz \
    && mv ngrok /usr/bin/ngrok \
    && apt clean

# VNC Password (123456)
RUN mkdir -p /root/.vnc && \
    echo "123456" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Startup Script
# මෙතන <YOUR_NGROK_AUTH_TOKEN> වෙනුවට උඹේ Token එක දාපන්
RUN echo '#!/bin/bash\n\
rm -rf /tmp/.X*\n\
vncserver :1 -geometry 1280x720 -depth 24\n\
ngrok config add-authtoken <YOUR_NGROK_AUTH_TOKEN>\n\
ngrok tcp 5901' > /entrypoint.sh && chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
