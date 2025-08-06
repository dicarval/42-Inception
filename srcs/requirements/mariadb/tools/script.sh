#!/bin/sh
DOMAIN="$USER$DOMAIN_SUFFIX"

# Starting and configuring MariaDB #
echo "Configuring MariaDB ..."
service mariadb start > /dev/null
mariadb -e "CREATE DATABASE IF NOT EXISTS \`$DOMAIN\` ;"
mariadb -e "CREATE USER IF NOT EXISTS '$USER'@'%' IDENTIFIED BY '$DB_USER_PASSWORD' ;"
mariadb -e "GRANT ALL PRIVILEGES ON \`$DOMAIN\`.* TO '$USER'@'%' IDENTIFIED BY '$DB_ROOT_PASSWORD';"
mariadb -e "FLUSH PRIVILEGES ;"

# Reseting MariaDB so the changes take effect #
sleep 2
service mariadb stop > /dev/null
echo "MariaDB is ready!"
exec mariadbd-safe --bind-address=0.0.0.0 > /dev/null
