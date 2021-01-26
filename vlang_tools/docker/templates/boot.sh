#!/usr/bin/dumb-init /bin/sh
set -ex

if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	# generate fresh rsa key
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ]; then
	# generate fresh dsa key
	ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
fi

#prepare run dir
if [ ! -d "/var/run/sshd" ]; then
  mkdir -p /var/run/sshd
fi

mkdir -p /root/.ssh/
# cp /myhost/authorized_keys /root/.ssh/authorized_keys

if [ ! -L "/root/.ssh/authorized_keys" ]; then
  ln -s /myhost/authorized_keys /root/.ssh/authorized_keys
fi

# chmod 600 /root/.ssh/authorized_keys
passwd -u root || true  #to get pam to work


#no -D because then goes to background
/usr/sbin/sshd

# @if redis_enable {
# redis-server /etc/redis.conf  --daemonize yes
# }


sh