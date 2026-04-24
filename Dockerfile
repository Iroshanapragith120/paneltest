FROM debian:11-slim

# ENV variables සෙට් කිරීම
ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV DISPLAY=:1

# අත්‍යවශ්‍ය ටූල්ස් සහ Browser දෙක (Chrome + Firefox) ඉන්ස්ටෝල් කිරීම
RUN apt update && apt install -y \
    xfce4 xfce4-terminal \
    tightvncserver novnc websockify \
    wget curl ca-certificates procps \
    firefox-esr \
    # Google Chrome ඉන්ස්ටෝල් කිරීම
    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt install -y ./google-chrome-stable_current_amd64.deb \
    && rm google-chrome-stable_current_amd64.deb \
    && apt clean

# VNC Password එක (123456)
RUN mkdir -p ~/.vnc && \
    echo "123456" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

# Startup Script එක
# Chrome එක Root විදිහට දුවන්න '--no-sandbox' අවශ්‍යයි
RUN echo '#!/bin/bash\n\
rm -rf /tmp/.X*\n\
vncserver :1 -geometry 1280x720 -depth 24\n\
websockify --web /usr/share/novnc/ 8080 localhost:5901 &\n\
echo "RDP is Ready! Open your link and add /vnc.html"\n\
tail -f /dev/null' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 8080

CMD ["/bin/bash", "/entrypoint.sh"]
