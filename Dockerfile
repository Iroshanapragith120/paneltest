FROM ubuntu:24.04

# අත්‍යවශ්‍ය ටූල්ස් ඉන්ස්ටෝල් කිරීම
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    bash \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# 3x-ui ඉන්ස්ටෝල් කරන එක
RUN curl -Ls https://raw.githubusercontent.com/mhzm/3x-ui/master/install.sh | bash -s -- -y

# පැනල් එකේ විස්තර කමාන්ඩ් එකෙන් සෙට් කරනවා
# Username: admin123
# Password: password123
# Port: 8080 (Replit එකට ලේසි වෙන්න)
RUN /usr/local/x-ui/x-ui setting -username admin123 -password password123
RUN /usr/local/x-ui/x-ui setting -port 8080

# Replit එක පෝට් එක අඳුරගන්න
EXPOSE 8080

# පැනල් එක රන් කිරීම
CMD ["/usr/local/x-ui/x-ui"]
