#!/bin/bash
DOMAIN="https://$USER$DOMAIN_SUFFIX"
DB_NAME="${USER}_42"
DB_ROOT_PASSWORD=$(cat ${DB_PASSWORD_FILE:-/run/secrets/db_root_password})
WP_ADMIN_PASSWORD=$(cat ${ADMIN_PASSWORD_FILE:-/run/secrets/wp_admin_password})
WP_USER_PASSWORD=$(cat ${USER_PASSWORD_FILE:-/run/secrets/wp_user_password})

INIT_MARKER="/var/www/html/.initialized"

if [ ! -f "$INIT_MARKER" ]; then
  cd /var/www/html

  # Installing Wordpress Command Line Interface #
  echo "Installing Wordpress Command Line Interface (WP-CLI)..."
  curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  mv wp-cli.phar /usr/local/bin/wp

  # Waiting for MariaDB configuration #
  while ! nc -z mariadb 3306 > /dev/null 2>&1; do
    echo "Waiting for MariaDB connection..."
    sleep 2
  done

  # Downloading and Configuring Wordpress #
  echo "Downloading and Configuring Wordpress..."
  wp core download --allow-root > /dev/null 2>&1
  wp config create --allow-root \
  --dbname=$DB_NAME \
  --dbuser=$USER \
  --dbpass=$DB_ROOT_PASSWORD \
  --dbhost=mariadb:3306 > /dev/null 2>&1

  # Installing Wordpress #
  echo "Installing Wordpress..."
  echo "Creating admin..."
  wp core install --skip-email --allow-root \
  --url="$DOMAIN" \
  --title="$WP_TITLE" \
  --admin_user="$WP_ADMIN_USER" \
  --admin_password="$WP_ADMIN_PASSWORD" \
  --admin_email="$WP_ADMIN_EMAIL" > /dev/null 2>&1

  # Ensure Redis constants are set in the correct place
  echo "Installing Redis..."
  WP_PATH="/var/www/html"
  wp config set WP_REDIS_CLIENT phpredis --allow-root --path="$WP_PATH" > /dev/null 2>&1
  wp config set WP_REDIS_HOST redis --allow-root --path="$WP_PATH" > /dev/null 2>&1
  wp config set WP_REDIS_PORT 6379 --raw --allow-root --path="$WP_PATH" > /dev/null 2>&1

  # Install plugin but don't activate until Redis is reachable
  wp plugin install redis-cache --allow-root --path="$WP_PATH" > /dev/null 2>&1
  while ! nc -z redis 6379 > /dev/null 2>&1; do
    echo "Waiting for Redis connection..."
    sleep 1
  done
  wp plugin activate redis-cache --allow-root --path="$WP_PATH" > /dev/null 2>&1
  wp redis enable --allow-root --path="$WP_PATH" > /dev/null 2>&1

  chown -R www-data:www-data /var/www/html
  find /var/www/html -type d -exec chmod 755 {} \; || true
  find /var/www/html -type f -exec chmod 644 {} \; || true

  # Creating an user #
  echo "Creating user..."
  wp user create --role=author --allow-root \
  --user_pass=$WP_USER_PASSWORD $USER $USER_EMAIL > /dev/null 2>&1

  # Making Wordpress listen to 9000 #
  sed -i "s#^listen\s*=.*#listen = 0.0.0.0:9000#" /etc/php/8.2/fpm/pool.d/www.conf

  echo "Installing theme..."
  wp theme install feature --activate --allow-root > /dev/null 2>&1

  # Initializing PHP FastCGI Process Manager #
  echo "Initializing PHP-FPM..."
  touch "$INIT_MARKER"
fi

echo "Wordpress is ready!"

exec php-fpm8.2 -F
