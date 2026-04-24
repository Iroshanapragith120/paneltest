FROM accetto/ubuntu-vnc-xfce

ENV VNC_PW=1223456
ENV VNC_RESOLUTION=1920x1080
ENV VNC_COL_DEPTH=24

# Chrome install කරන්න
USER 0
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && \
    apt-get install -y ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb && \
    apt-get clean

# Wine install කරන්න .exe රන් කරන්න
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y wine64 wine32 winetricks && \
    apt-get clean

USER 1000
