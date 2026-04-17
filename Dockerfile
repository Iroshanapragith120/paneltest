FROM ubuntu:24.04

# අත්‍යවශ්‍ය ටූල්ස් ඉන්ස්ටෝල් කිරීම
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    bash \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# 3x-ui ඉන්ස්ටෝල් කිරීම
RUN curl -Ls https://raw.githubusercontent.com/mhzm/3x-ui/master/install.sh | bash -s -- -y

# Replit එකේ පෝට් එකට පැනල් එක සෙට් කිරීම
RUN /usr/local/x-ui/x-ui setting -port 8080

EXPOSE 8080

# මෙන්න මේ පේළිය තමයි වැදගත්ම! 
# මේකෙන් පැනල් එකයි ටර්මිනල් එකයි දෙකම පණගන්වනවා.
CMD /usr/local/x-ui/x-ui start && tail -f /dev/null
