FROM ubuntu:22.04

RUN apt update && apt install -y curl wget supervisor sqlite3

# 3x-ui ඉන්ස්ටෝල් කරමු (Render එකට ගැලපෙන විදියට)
RUN bash -c "$(curl -L https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)" <<EOF
y
admin
admin123
10000
EOF

# Cloudflared ඉන්ස්ටෝල් කරමු
RUN wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && \
    dpkg -i cloudflared-linux-amd64.deb

# Supervisor Config එක හදමු
RUN printf "[supervisord]\nnodaemon=true\nuser=root\n\n[program:3x-ui]\ncommand=/usr/local/x-ui/x-ui\ndirectory=/usr/local/x-ui\nautostart=true\nautorestart=true\n\n[program:cloudflare]\ncommand=cloudflared tunnel --url http://localhost:10000\nautostart=true\nautorestart=true" > /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /var/log/supervisor
EXPOSE 10000
CMD ["/usr/bin/supervisord"]
