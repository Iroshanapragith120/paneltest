FROM ubuntu:22.04

# ENV variables සෙට් කිරීම
ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV DISPLAY=:1

# අවශ්‍ය ටූල්ස් ඉන්ස්ටෝල් කිරීම (Firefox සහ Desktop ඇතුළුව)
RUN apt update && apt install -y \
    xfce4 xfce4-goodies \
    tightvncserver \
    novnc websockify \
    firefox \
    wget curl && \
    apt clean

# VNC Password එක සෙට් කිරීම (පාස්වර්ඩ් එක: 123456)
RUN mkdir -p ~/.vnc && \
    echo "123456" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

# Startup Script එක ඇතුළතදීම ලිවීම
RUN echo '#!/bin/bash\n\
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1\n\
vncserver :1 -geometry 1280x720 -depth 24\n\
websockify --web /usr/share/novnc/ 8080 localhost:5901\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

# Railway පෝර්ට් එක
EXPOSE 8080

# සර්වර් එක දිගටම රන් වෙන්න දාන කමාන්ඩ් එක
CMD ["/entrypoint.sh"]
