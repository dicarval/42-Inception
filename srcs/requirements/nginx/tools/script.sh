#!/bin/sh
DOMAIN="$USER$DOMAIN_SUFFIX"

if [ -f /nginx_server.conf ]; then

  # Generating a self signing certificate and a private key with OpenSSL #
  echo "Generating key and certificate (OpenSSL) ..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/$DOMAIN.key \
  -out /etc/ssl/certs/$DOMAIN.crt \
  -subj "/C=PT/L=Lisbon/O=42Lisboa/OU=student/CN=$DOMAIN/UID=$USER" > /dev/null 2>&1

  # Configuring nginx #
  echo "Configuring Nginx ..."
  sed -i "s/domain/$DOMAIN/g" nginx_server.conf
  mkdir -p /run/nginx /etc/nginx/conf.d
  mv nginx_server.conf /etc/nginx/conf.d/$DOMAIN.conf

    # Remove default site to avoid the default_server on port 80
  if [ -f /etc/nginx/conf.d/default.conf ]; then
    rm -f /etc/nginx/conf.d/default.conf
  fi

fi

echo "Nginx is ready!"
nginx -g "daemon off;"
