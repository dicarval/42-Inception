#!/bin/bash
DOMAIN="$USER$DOMAIN_SUFFIX"
PAR_CONF="/parallax_server.conf"

if [ -f "$PAR_CONF" ]; then
  echo "Installing parallax site config for $DOMAIN"
  mkdir -p /run/nginx
  mv "$PAR_CONF" /etc/nginx/conf.d/parallax.conf
  chmod 644 /etc/nginx/conf.d/parallax.conf
  sed -i "s/domain/$DOMAIN/g" /etc/nginx/conf.d/parallax.conf
fi

echo "Parallax is ready!"
exec nginx -g "daemon off;"
