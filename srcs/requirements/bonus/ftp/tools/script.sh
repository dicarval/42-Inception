#!/bin/sh

FT_PASS=$(cat ${FTP_PASSWORD:-/run/secrets/ftp_password})

mkdir -p /home/$USER/wordpress
chown root:root /home/$USER
chmod 755 /home/$USER
chmod a-w /home/$USER

# Create FTP user and set password
echo "Creating FTP user"
adduser -D -h /home/$USER/wordpress $USER > /dev/null 2>&1
echo "${USER}:${FT_PASS}" | chpasswd

chown -R $USER:$USER /home/$USER/wordpress
chmod g-s /home/$USER/wordpress

# Simple vsftpd.conf
echo "Configuring the server"
cat <<EOF > /etc/vsftpd/vsftpd.conf
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
chroot_local_user=YES
allow_writeable_chroot=YES
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110

# Debug/logging to /var/log/vsftpd.log
xferlog_enable=YES
xferlog_file=/var/log/vsftpd.log
vsftpd_log_file=/var/log/vsftpd.log
log_ftp_protocol=YES
dual_log_enable=YES

# Disable seccomp sandbox (fixes "child died" in some Alpine/container setups)
seccomp_sandbox=NO
EOF

echo "Starting vsftpd..."
mkdir -p /var/run/vsftpd/empty
chmod 755 /var/run/vsftpd/empty
touch /var/log/vsftpd.log
chown root:root /var/log/vsftpd.log

exec vsftpd /etc/vsftpd/vsftpd.conf
