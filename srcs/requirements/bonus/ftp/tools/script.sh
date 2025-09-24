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
#anonymous_enable=NO
local_enable=YES
write_enable=YES
#local_umask=022
#chroot_local_user=YES
#allow_writeable_chroot=YES
#pasv_enable=YES
#pasv_min_port=21100
#pasv_max_port=21110
EOF

echo "Starting vsftpd..."
ls -ld /home/$USER
ls -ld /home/$USER/wordpress
ls -l /home/$USER
exec vsftpd /etc/vsftpd/vsftpd.conf -olisten=NO -obackground=NO
