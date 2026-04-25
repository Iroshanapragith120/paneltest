FROM kasmweb/tor-browser:1.14.0

USER root

# 1. Railway එකට ඕන Port එක ENV එකෙන් ගන්නවා
ENV PORT=8080
ENV VNC_PW=password
ENV VNC_RESOLUTION=1280x720

# 2. Kasm එකේ Port එක 8080 ට මාරු කරනවා
RUN sed -i 's/6901/8080/g' /etc/nginx/sites-available/default && \
    sed -i 's/6901/8080/g' /dockerstartup/vnc_startup.sh

EXPOSE 8080

USER 1000

# 3. Start command එක Force කරනවා
CMD ["/dockerstartup/kasm_default_profile.sh", "/dockerstartup/vnc_startup.sh", "--wait"]
