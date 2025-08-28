#!/bin/sh
DOMAIN="$USER$DOMAIN_SUFFIX"
DB_NAME="${USER}_42"
DB_ROOT_PASSWORD=$(cat ${ROOT_PASSWORD_FILE:-/run/secrets/db_root_password})
DB_USER_PASSWORD=$(cat ${USER_PASSWORD_FILE:-/run/secrets/db_user_password})

# Starting and configuring MariaDB #
echo "Configuring MariaDB ..."

# Initialize MariaDB data directory if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

	# Start MariaDB temporarily for configuration
	mariadbd-safe --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 --skip-networking &
	MYSQL_PID=$!

	# Wait for MariaDB to be ready
	until mariadb-admin ping > /dev/null 2>&1; do
		echo "Waiting for MariaDB to start..."
		sleep 1
	done

	# Configure database and user
	mariadb -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` ;"
	mariadb -e "CREATE USER IF NOT EXISTS '$USER'@'%' IDENTIFIED BY '$DB_USER_PASSWORD' ;"
	mariadb -e "GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$USER'@'%' IDENTIFIED BY '$DB_ROOT_PASSWORD';"
	mariadb -e "FLUSH PRIVILEGES ;"

	# Graceful shutdown
	mariadb-admin shutdown
	wait $MYSQL_PID
fi

echo "MariaDB is ready!"

# Start as main container process
exec mariadbd-safe --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 --skip-networking=0 > /dev/null
