FROM debian:11

ENV DEBIAN_FRONTEND=noninteractive

# අවශ්‍ය ටූල්ස් සහ 3X-UI පැනල් එක ඉන්ස්ටෝල් කිරීම
RUN apt update && apt install -y \
    curl wget sudo procps ca-certificates \
    && bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) \
    && apt clean

# Cloudflare Tunnel එක ඉන්ස්ටෝල් කිරීම
RUN wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
    && dpkg -i cloudflared-linux-amd64.deb

# Startup Script එක
RUN echo '#!/bin/bash\n\
/usr/local/x-ui/x-ui start\n\
echo "Panel Started. Waiting for Cloudflare Tunnel..."\n\
# 2053 කියන්නේ 3x-ui වල default port එක\n\
cloudflared tunnel --url http://localhost:2053' > /entrypoint.sh && chmod +x /entrypoint.sh

# Railway එකට Port එක පෙන්වීම
EXPOSE 2053

CMD ["/bin/bash", "/entrypoint.sh"]
