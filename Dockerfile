FROM kasmweb/tor-browser:1.14.0

USER root

# 1. Kasm එකට කෙලින්ම කියනවා 8080 Port එකේ Run වෙන්න කියලා
ENV KASM_VNC_LISTEN_PORT=8080
ENV VNC_PW=password
ENV VNC_RESOLUTION=1280x720
ENV MAX_FRAME_RATE=24

# 2. Railway එකටත් කියනවා
ENV PORT=8080
EXPOSE 8080

USER 1000
