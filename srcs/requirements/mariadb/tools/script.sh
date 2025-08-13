#!/bin/sh
DOMAIN="$USER$DOMAIN_SUFFIX"
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password.txt)
DB_USER_PASSWORD=$(cat /run/secrets/db_user_password.txt)

# Starting and configuring MariaDB #
echo "Configuring MariaDB ..."

# Initialize MariaDB data directory if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
	mysql_install_db --user=mysql --datadir=/var/lib/mysql


	# Start MariaDB temporarily for configuration
	mysqld_safe --user=mysql --datadir=/var/lib/mysql --skip-networking &
	MYSQL_PID=$!

	# Wait for MariaDB to be ready
	until mysqladmin ping >/dev/null 2>&1; do
		echo "Waiting for MariaDB to start..."
		sleep 1
	done

	# Configure database and user
	mariadb -e "CREATE DATABASE IF NOT EXISTS \`$DOMAIN\` ;"
	mariadb -e "CREATE USER IF NOT EXISTS '$USER'@'%' IDENTIFIED BY '$DB_USER_PASSWORD' ;"
	mariadb -e "GRANT ALL PRIVILEGES ON \`$DOMAIN\`.* TO '$USER'@'%' IDENTIFIED BY '$DB_ROOT_PASSWORD';"
	mariadb -e "FLUSH PRIVILEGES ;"

	# Graceful shutdown
	mysqladmin shutdown
	wait $MYSQL_PID
fi

echo "MariaDB is ready!"

# Start as main container process
exec mysqld_safe --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 > /dev/null
