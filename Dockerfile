FROM ubuntu:22.04

# ENV variables set කිරීම
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

# අවශ්‍ය ටූල්ස් ඉන්ස්ටෝල් කිරීම
RUN apt update && apt install -y \
    xfce4 xfce4-goodies \
    tightvncserver \
    novnc websockify \
    firefox \
    curl wget && \
    apt clean

# VNC Password එක සෙට් කිරීම (මෙහි පාස්වර්ඩ් එක 123456)
RUN mkdir -p ~/.vnc && \
    echo "123456" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

# Startup Script එක ලිවීම
RUN echo "#!/bin/bash\n\
vncserver :1 -geometry 1280x720 -depth 24\n\
websockify --web /usr/share/novnc/ 8080 localhost:5901\n" > /start.sh && \
    chmod +x /start.sh

# Railway එකේ PORT එක open කිරීම
EXPOSE 8080

CMD ["/start.sh"]
