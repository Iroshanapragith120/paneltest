# Ubuntu 24.04 පාවිච්චි කරමු
FROM ubuntu:24.04

# අත්‍යවශ්‍ය ටූල්ස් ඉන්ස්ටෝල් කිරීම
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    bash \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# 3x-ui ඉන්ස්ටෝල් කරන ස්ක්‍රිප්ට් එක රන් කිරීම
# මේකෙදි අපි -s (silent) සහ auto-install පාවිච්චි කරනවා
RUN curl -Ls https://raw.githubusercontent.com/mhzm/3x-ui/master/install.sh | bash -s -- -y

# පැනල් එකේ Default Port එක 2053 (මේක Replit එකේදී 8080 ට Map කරන්න වෙයි)
EXPOSE 2053

# පැනල් එක පණගන්වා තබා ගැනීමට
CMD ["/usr/local/x-ui/x-ui", "start"]
