#!/bin/bash

FT_PASS=$(cat ${FTP_PASSWORD:-/run/secrets/ftp_password})

INIT_MARKER="/home/$USER/wordpress/.initialized"

if [ ! -f "$INIT_MARKER" ]; then

  # Create FTP user and set password
  echo "Creating FTP user"
  adduser --gecos "" --disabled-password "$USER" > /dev/null 2>&1
  usermod -d /home/"$USER"/wordpress "$USER"

  # make ftp user part of www-data group so it can write without changing owner
  usermod -aG www-data "$USER"
  chown -R www-data:www-data /home/$USER/wordpress 2>/dev/null
  find /home/$USER/wordpress -type d -exec chmod 775 {} \;
  find /home/$USER/wordpress -type f -exec chmod 664 {} \;
  echo "${USER}:${FT_PASS}" | chpasswd


  # Simple vsftpd.conf
  echo "Configuring the server"
  cat <<EOF > /etc/vsftpd.conf
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
EOF

  mkdir -p /var/run/vsftpd/empty && chmod 755 /var/run/vsftpd/empty
  touch $INIT_MARKER
fi

echo "Starting vsftpd..."

# start as child to be able to gracefully stop the container
vsftpd /etc/vsftpd.conf &
VSFTPD_PID=$!

graceful_stop() {
  # send TERM to the PID
  kill -TERM -- -"$VSFTPD_PID" 2>/dev/null || kill -TERM "$VSFTPD_PID" 2>/dev/null

  # wait up to ~2s
  for i in {1..20}; do
    kill -0 "$VSFTPD_PID" 2>/dev/null || break
    sleep 0.1
  done

  if kill -0 "$VSFTPD_PID" 2>/dev/null; then
    kill -KILL -- -"$VSFTPD_PID" 2>/dev/null || kill -KILL "$VSFTPD_PID" 2>/dev/null
  fi

  wait "$VSFTPD_PID" 2>/dev/null
  exit 0
}

trap graceful_stop SIGTERM SIGINT
wait "$VSFTPD_PID"
exit 0
