FROM debian:11-slim

ENV DEBIAN_FRONTEND=noninteractive

# අවශ්‍ය ටූල්ස් ටික විතරක් දාමු
RUN apt update && apt install -y \
    curl wget procps ca-certificates tar \
    && apt clean

# 3X-UI අතින් (Manual) බාගෙන සෙට් කරමු (Script එක නැතුව)
RUN mkdir -p /usr/local/x-ui && \
    curl -Ls https://github.com/mhsanaei/3x-ui/releases/latest/download/x-ui-linux-amd64.tar.gz -o /tmp/x-ui.tar.gz && \
    tar zxvf /tmp/x-ui.tar.gz -C /usr/local/ && \
    rm /tmp/x-ui.tar.gz

# Cloudflare Tunnel දාමු (Port ප්‍රශ්න නැති වෙන්න)
RUN wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && \
    dpkg -i cloudflared-linux-amd64.deb

WORKDIR /usr/local/x-ui

# සර්වර් එක පණගන්වන Script එක
RUN echo '#!/bin/bash\n\
./x-ui &\n\
echo "Waiting for Panel..."\n\
sleep 5\n\
cloudflared tunnel --url http://localhost:2053' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 2053

CMD ["/bin/bash", "/entrypoint.sh"]
