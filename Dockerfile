FROM chernetsov0/nginx-alpine:1.13.2

LABEL maintainer="Alexey Chernetsov <chernetsov0@gmail.com>"

# Default environment
ENV DHLEVEL=2048

# Install Certbot and openssl
RUN apk add --no-cache certbot openssl

# Create directories.
RUN mkdir -p /var/lib/nginx-letsencrypt /usr/share/nginx/acme

# Add local files
COPY etc/ /etc/
COPY nginx-letsencrypt.sh /root/nginx-letsencrypt

# Make scripts executable
RUN chmod a+x \
    /root/nginx-letsencrypt \
    /etc/periodic/daily/10-letsencrypt-renew

CMD /root/nginx-letsencrypt
