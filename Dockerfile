FROM debian:latest

# 1. Timezone සහ අවශ්‍ය පැකේජ් ඉන්ස්ටෝල් කිරීම
RUN apt-get update && apt-get install -y \
    curl \
    bash \
    sudo \
    sqlite3 \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# 2. Timezone එක Asia/Colombo වලට සෙට් කිරීම (Unknown Timezone එරර් එකට විසඳුම)
ENV TZ=Asia/Colombo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 3. 3x-ui පැනල් එක ඉන්ස්ටෝල් කිරීම
RUN bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) v2.4.6

# 4. පැනල් එකේ Username, Password සහ Port එක කලින්ම සෙට් කිරීම
# මෙතන 'admin' සහ 'pass123' වෙනුවට ඔයාට ඕන එකක් දාන්න පුළුවන්
RUN sqlite3 /etc/x-ui/x-ui.db "UPDATE users SET username='admin', password='pass123' WHERE id=1;"
RUN sqlite3 /etc/x-ui/x-ui.db "UPDATE settings SET value='2053' WHERE key='panelPort';"

# පැනල් එකට අවශ්‍ය Port එක විවෘත කිරීම
EXPOSE 2053

# 5. පැනල් එක ස්ටාර්ට් කිරීම
CMD ["/usr/local/x-ui/x-ui"]
