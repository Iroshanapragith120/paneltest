FROM debian:11

ENV DEBIAN_FRONTEND=noninteractive

# අවශ්‍ය ටූල්ස් සහ 3X-UI ඉන්ස්ටෝල් කිරීම
RUN apt update && apt install -y \
    curl wget sudo procps ca-certificates socat \
    && bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) \
    && apt clean

# Cloudflare Tunnel ඉන්ස්ටෝල් කිරීම
RUN wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
    && dpkg -i cloudflared-linux-amd64.deb

# Acme.sh ඉන්ස්ටෝල් කිරීම (SSL ගන්න පාවිච්චි කරන්නේ මේකයි)
RUN curl https://get.acme.sh | sh -s email=my@example.com

# Startup Script එක
# මෙතන $PORT පාවිච්චි කරන්නේ Railway එකේ dynamic port එකට සෙට් වෙන්න
RUN echo '#!/bin/bash\n\
/usr/local/x-ui/x-ui start\n\
echo "3X-UI Started."\n\
\n\
# උඹට menu එකේ 19 ගිහින් කරන්න ඕන දේ (SSL certificate එක install කරන එක)\n\
# ඒක පැනල් එක ඇතුළෙන්ම කරන්න පුළුවන් නිසා අපි Cloudflare Tunnel එක run කරමු\n\
echo "Starting Cloudflare Tunnel..."\n\
cloudflared tunnel --url http://localhost:2053' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 2053

CMD ["/bin/bash", "/entrypoint.sh"]
