# Ubuntu 24.04 පදනම් කරගත් image එක
FROM ubuntu:24.04

# අත්‍යවශ්‍ය ටූල්ස් ඉන්ස්ටෝල් කිරීම
RUN apt-get update && apt-get install -y \
    ttyd \
    bash \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Terminal එක වැඩ කරන Port එක (7681 තමයි ttyd default පාවිච්චි කරන්නේ)
EXPOSE 7681

# Replit එකට ගැලපෙන විදිහට ttyd run කිරීම
CMD ["ttyd", "-p", "8080", "-i", "0.0.0.0", "bash"]
