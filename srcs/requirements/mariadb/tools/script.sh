#!/bin/sh
DOMAIN="$USER$DOMAIN_SUFFIX"
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password.txt)
DB_USER_PASSWORD=$(cat /run/secrets/db_user_password.txt)

# Starting and configuring MariaDB #
echo "Configuring MariaDB ..."

# Initialize MariaDB data directory if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql

	# Start MariaDB temporarily for configuration
	mariadbd-safe --user=mysql --datadir=/var/lib/mysql &
	MYSQL_PID=$!

	# Wait for MariaDB to be ready
	until mariadb-admin ping >/dev/null 2>&1; do
		echo "Waiting for MariaDB to start..."
		sleep 1
	done

	# Configure database and user
	mariadb -e "CREATE DATABASE IF NOT EXISTS \`$DOMAIN\` ;"
	mariadb -e "CREATE USER IF NOT EXISTS '$USER'@'%' IDENTIFIED BY '$DB_USER_PASSWORD' ;"
	mariadb -e "GRANT ALL PRIVILEGES ON \`$DOMAIN\`.* TO '$USER'@'%' ;"
	mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}' ;"
	mariadb -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${DB_ROOT_PASSWORD}') ;"
	mariadb -e "FLUSH PRIVILEGES ;"

	# Graceful shutdown
	mariadb-admin shutdown
	wait $MYSQL_PID
fi

echo "MariaDB is ready!"

# Start as main container process
exec mariadbd-safe --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0
