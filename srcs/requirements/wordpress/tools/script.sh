#!/bin/sh
DOMAIN="$USER$DOMAIN_SUFFIX"
DB_NAME="${USER}_42"
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password.txt)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password.txt)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password.txt)



if [ ! -d /run/php ]; then
  # Creating configuration directory #
  mkdir -p /var/www/html && cd /var/www/html

  # Removing possible previous content #
  rm -rf *

  # Installing Wordpress Command Line Interface #
  echo "Installing Wordpress Command Line Interface (WP-CLI)..."
  curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  mv wp-cli.phar /usr/local/bin/wp

  # Waiting for MariaDB configuration #
  while ! nc -z mariadb 3306 ; do
    echo "Waiting for MariaDB connection..."
    sleep 5
  done

# Downloading and Configuring Wordpress #
  echo "Downloading and Configuring Wordpress..."
  php -d memory_limit=512M /usr/local/bin/wp core download --allow-root
  wp config create --allow-root \
  --dbname=$DB_NAME \
  --dbuser=$USER \
  --dbpass=$DB_ROOT_PASSWORD \
  --dbhost=mariadb:3306 > /dev/null

  # Installing Wordpress #
  echo "Installing Wordpress..."
  echo "Creating admin..."
  wp core install --skip-email --allow-root \
  --url="$DOMAIN" \
  --title="$WP_TITLE" \
  --admin_user="$WP_ADMIN_USER" \
  --admin_password="$WP_ADMIN_PASSWORD" \
  --admin_email="$WP_ADMIN_EMAIL" > /dev/null

  # Creating an user #
  echo "Creating user..."
  wp user create --role=author --allow-root \
  --user_pass=$WP_USER_PASSWORD $USER $USER_EMAIL > /dev/null

  # Initializing PHP FastCGI Process Manager #
  echo "Initializing PHP-FPM..."
  mkdir /run/php
fi

echo "Wordpress is ready!"

if command -v php-fpm >/dev/null 2>&1; then
  exec php-fpm -F
elif command -v php-fpm8 >/dev/null 2>&1; then
  exec php-fpm8 -F
elif command -v php-fpm83 >/dev/null 2>&1; then
  exec php-fpm83 -F
else
  echo "ERROR: php-fpm binary not found" >&2
  exit 1
fi
