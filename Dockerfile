FROM debian:11

# අවශ්‍ය ටූල්ස් ඉන්ස්ටෝල් කිරීම
ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV DISPLAY=:1

RUN apt update && apt install -y \
    xfce4 xfce4-terminal xfce4-settings \
    tightvncserver novnc websockify \
    wget curl ca-certificates procps \
    dbus-x11 x11-xserver-utils \
    firefox-esr \
    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt install -y ./google-chrome-stable_current_amd64.deb \
    && rm google-chrome-stable_current_amd64.deb \
    && apt clean

# VNC එකට අලුතින්ම configuration එකක් හදමු
RUN mkdir -p /root/.vnc && \
    echo "123456" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# XStartup එක අලුතින්ම ලියමු (Desktop එක එන්න)
RUN echo "#!/bin/sh\n\
xrdb \$HOME/.Xresources\n\
startxfce4 &" > /root/.vnc/xstartup && chmod +x /root/.vnc/xstartup

# සර්වර් එක ස්ටාර්ට් කරන script එක
RUN echo '#!/bin/bash\n\
rm -rf /tmp/.X* /tmp/.X11-unix/*\n\
vncserver :1 -geometry 1280x720 -depth 24 -rfbauth /root/.vnc/passwd\n\
websockify --web /usr/share/novnc/ 8080 localhost:5901 &\n\
tail -f /dev/null' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 8080
CMD ["/bin/bash", "/entrypoint.sh"]
