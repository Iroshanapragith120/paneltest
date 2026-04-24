FROM debian:11

# අවශ්‍ය ටූල්ස් සහ Desktop එක ඉන්ස්ටෝල් කිරීම
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y \
    xfce4 xfce4-terminal xfce4-settings \
    tightvncserver novnc websockify \
    wget curl ca-certificates procps \
    dbus-x11 x11-xserver-utils \
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

# X startup එක - මේක තමයි dbus ලෙඩේ හැදෙන තැන
RUN echo "#!/bin/sh\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
dbus-launch --exit-with-session startxfce4 &" > ~/.vnc/xstartup && chmod +x ~/.vnc/xstartup

# සර්වර් එක පණගන්වන ස්ක්‍රිප්ට් එක
RUN echo '#!/bin/bash\n\
rm -rf /tmp/.X*\n\
vncserver :1 -geometry 1280x720 -depth 24\n\
websockify --web /usr/share/novnc/ 8080 localhost:5901 &\n\
tail -f /dev/null' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 8080
CMD ["/bin/bash", "/entrypoint.sh"]
