FROM kasmweb/tor-browser:1.14.0

# 1. Railway එකට ඕන Port එක කියනවා
ENV PORT=6901
EXPOSE 6901

# 2. Login Password Set කරනවා
ENV VNC_PW=password

# 3. Quality Settings - ඕන නම් වෙනස් කරපන්
ENV VNC_RESOLUTION=1280x720
ENV MAX_FRAME_RATE=24

USER 1000
