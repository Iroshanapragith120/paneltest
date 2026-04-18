# 1. Ubuntu 22.04 පාවිච්චි කිරීම
FROM ubuntu:22.04

# 2. අවශ්‍ය ටූල්ස් ඉන්ස්ටෝල් කිරීම (Ubuntu නිසා DEBIAN_FRONTEND එක දාන්න ඕනේ)
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    curl \
    bash \
    sudo \
    sqlite3 \
    tzdata \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 3. Timezone එක Asia/Colombo වලට සෙට් කිරීම
ENV TZ=Asia/Colombo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 4. 3x-ui පැනල් එක ඉන්ස්ටෝල් කිරීම
RUN bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) v2.4.6

# 5. ඩේටාබේස් එක හදලා Username/Password සහ Port එක කෙලින්ම සෙට් කිරීම
# Username: admin | Password: adminpassword | Port: 2053
RUN mkdir -p /etc/x-ui/ && \
    sqlite3 /etc/x-ui/x-ui.db "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT, port INTEGER, tnetmask TEXT, max_users INTEGER, status INTEGER, expiry_time INTEGER);" && \
    sqlite3 /etc/x-ui/x-ui.db "INSERT OR REPLACE INTO users (id, username, password, port, tnetmask, max_users, status, expiry_time) VALUES (1, 'admin', 'adminpassword', 2053, '', 0, 1, 0);" && \
    sqlite3 /etc/x-ui/x-ui.db "CREATE TABLE IF NOT EXISTS settings (id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT, value TEXT);" && \
    sqlite3 /etc/x-ui/x-ui.db "INSERT OR REPLACE INTO settings (id, key, value) VALUES (1, 'panelPort', '2053');"

# Replit එකේ 5000 පෝර්ට් එකට මැප් කරන්න ලෑස්ති කිරීම
EXPOSE 2053

# 6. පැනල් එක පණ ගැන්වීම
CMD ["/usr/local/x-ui/x-ui"]
