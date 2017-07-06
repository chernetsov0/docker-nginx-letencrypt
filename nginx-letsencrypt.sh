#!/bin/sh

# Check the environment o make sure that the required variables are set.
if [ -z "$DOMAINS" ]; then
  echo "Please pass your DOMAINS as an environment variable"
  exit 1
fi

# Load or create saved environment.
if [ ! -f "/var/lib/nginx-letsencrypt/current_env" ]; then
    echo -e "CURRENT_DOMAINS=\"$DOMAINS\" CURRENT_DHLEVEL=\"$DHLEVEL\"" > /var/lib/nginx-letsencrypt/current_env
fi

. /var/lib/nginx-letsencrypt/current_env

# Compare dhparams existence and level. (Re)create if necessary.
if [ ! "$DHLEVEL" = "$CURRENT_DHLEVEL" ]; then
  rm -rf /var/lib/nginx-letsencrypt/dhparams.pem
  echo "DH parameters size changed, deleting old file"
fi

if [ ! -f "/var/lib/nginx-letsencrypt/dhparams.pem" ]; then
  openssl dhparam -out /var/lib/nginx-letsencrypt/dhparams.pem "$DHLEVEL"
  echo "$DHLEVEL-bit parameters successfully created"
else
  echo "$DHLEVEL-bit DH parameters present"
fi

# Check whether to use e-mail when generating certificate.
if [ ! -z $EMAIL ]; then
  echo "E-mail address entered: ${EMAIL}"
  EMAILPARAM="-m ${EMAIL}"
else
  echo "No e-mail address entered, proceeding unsafely"
  EMAILPARAM="--register-unsafely-without-email"
fi

# Check for changes in DOMAINS.
# Revoke certificate if necessary.
if [ ! "$DOMAINS" = "$CURRENT_DOMAINS" ]; then
  echo "Different DOMAINS entered than what was used before"
  echo "Revoking and deleting existing certificate"

  certbot revoke --non-interactive \
    --cert-path /etc/letsencrypt/live/nginx-letsencrypt/fullchain.pem
fi

# Generate certificate if necessary.
if [ ! -f "/var/lib/nginx-letsencrypt/keys/fullchain.pem" ]; then
  echo "Generating new certificate"

  certbot certonly --non-interactive --agree-tos \
    --standalone --preferred-challenges tls-sni --rsa-key-size 4096 \
    --cert-name nginx-letsencrypt $EMAILPARAM -d $DOMAINS
else
  /etc/periodic/daily/10-letsencrypt-renew
fi

# Save environment.
echo -e "CURRENT_DOMAINS=\"$DOMAINS\" CURRENT_DHLEVEL=\"$DHLEVEL\"" > /var/lib/nginx-letsencrypt/current_env

# Start crond for autorenewal
crond -f -l 6 -L /dev/stdout &

# Start NGINX.
nginx -g "daemon off;"
