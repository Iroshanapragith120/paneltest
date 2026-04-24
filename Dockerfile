FROM debian:11-slim

# ENV variables සෙට් කිරීම
ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV DISPLAY=:1

# අවශ්‍ය ටූල්ස් සහ Desktop එක ඉන්ස්ටෝල් කිරීම
RUN apt update && apt install -y \
    xfce4 xfce4-terminal xfce4-settings \
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

# XFCE Desktop එක පේන්න ඕන Startup config එක හැදීම
RUN echo "#!/bin/sh\n\
xrdb \$HOME/.Xresources\n\
startxfce4 &" > ~/.vnc/xstartup && chmod +x ~/.vnc/xstartup

# සර්වර් එක පණගන්වන මැජික් ස්ක්‍රිප්ට් එක
RUN echo '#!/bin/bash\n\
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1\n\
vncserver :1 -geometry 1280x720 -depth 24\n\
websockify --web /usr/share/novnc/ 8080 localhost:5901 &\n\
echo "RDP is Ready! Go to your link and add /vnc.html"\n\
tail -f /dev/null' > /entrypoint.sh && chmod +x /entrypoint.sh

# Railway Port
EXPOSE 8080

# වැඩේ පටන් ගමු
CMD ["/bin/bash", "/entrypoint.sh"]
