FROM debian:11

ENV DEBIAN_FRONTEND=noninteractive

# අත්‍යවශ්‍ය දේවල් සහ Tmate ඉන්ස්ටෝල් කිරීම
RUN apt update && apt install -y \
    xfce4 xfce4-terminal tightvncserver \
    wget curl ca-certificates firefox-esr \
    tmate dbus-x11 \
    && apt clean

# VNC Password (123456)
RUN mkdir -p /root/.vnc && \
    echo "123456" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Startup Script
RUN echo '#!/bin/bash\n\
rm -rf /tmp/.X*\n\
vncserver :1 -geometry 1280x720 -depth 24\n\
# Tmate පණගන්වනවා ලෝකේ ඕනෑම තැනක ඉඳන් ලොග් වෙන්න\n\
tmate -S /tmp/tmate.sock new-session -d\n\
tmate -S /tmp/tmate.sock wait tmate-ready\n\
tmate -S /tmp/tmate.sock display -p "#{tmate_ssh}"\n\
tail -f /dev/null' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 8080
CMD ["/bin/bash", "/entrypoint.sh"]
