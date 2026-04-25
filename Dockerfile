FROM lscr.io/linuxserver/torbrowser:latest

# 1. Railway Port Set කරනවා
ENV PORT=3000
ENV CUSTOM_PORT=3000
ENV CUSTOM_HTTPS_PORT=3001

# 2. Password Set කරනවා
ENV PASSWORD=password
ENV TITLE="Tor Browser"

EXPOSE 3000

# 3. Health Check Disable කරනවා
HEALTHCHECK NONE
