FROM debian:latest

# අවශ්‍ය ටූල්ස් ඉන්ස්ටෝල් කිරීම
RUN apt-get update && apt-get install -y curl bash sudo sqlite3

# 3x-ui ඉන්ස්ටෝල් කිරීම
RUN bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) v2.4.6

# පැනල් එකේ Username, Password සහ Port එක කෙලින්ම සෙට් කරනවා
# මෙතන 'admin' වෙනුවට ඔයාට ඕන එකක් දාන්න පුළුවන්
RUN sqlite3 /etc/x-ui/x-ui.db "UPDATE users SET username='admin', password='password123' WHERE id=1;"
RUN sqlite3 /etc/x-ui/x-ui.db "UPDATE settings SET value='2053' WHERE key='panelPort';"

EXPOSE 2053

# පැනල් එක ස්ටාර්ට් කිරීම
CMD ["/usr/local/x-ui/x-ui"]
