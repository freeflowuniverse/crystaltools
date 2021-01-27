module docker

import rand
import os

pub const (
	bootfile = '#!/usr/bin/dumb-init /bin/sh
set -ex

if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	# generate fresh rsa key
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N "" -t rsa
fi
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ]; then
	# generate fresh dsa key
	ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N "" -t dsa
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
'

	dockerfile = '# FROM alpine:3.13
FROM \$base
RUN rm  -rf /tmp/* /var/cache/apk/*
RUN apk add --no-cache redis && apk add --no-cache dumb-init 
RUN apk add --no-cache curl libssh2

RUN echo "nameserver 8.8.8.8" > "/etc/resolv.conf"

# add openssh and clean
RUN apk add --no-cache openssh && rm  -rf /tmp/* /var/cache/apk/*

# add entrypoint script
ADD boot.sh /usr/local/bin

#make sure we get fresh keys
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key
RUN chmod 770 /usr/local/bin/boot.sh

RUN apk add --no-cache mc htop rsync

# @if redis_enable {
# RUN apk add --no-cache redis
# EXPOSE 6379
# }

EXPOSE 22

RUN echo "THREEFOLD BASE DEV ENV WELCOMES YOU" > /etc/motd

# ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/usr/local/bin/boot.sh"]
'
)


// build ssh enabled alpine docker image
// has default ssh key in there
pub fn (mut e DockerEngine) build() ?DockerImage{
	
	mut dest := '/tmp/$rand.uuid_v4()'
	println("Creating temp dir $dest")
	e.node.executor.exec("mkdir $dest")?
	
	base := "alpine:3.13"
	redis_enable := false
	
	df := dockerfile.replace("\$base", base).replace("redis_enable", "$redis_enable")
	e.node.executor.exec("echo '$df' > $dest/dockerfile")?
	e.node.executor.exec("echo '$bootfile' > $dest/boot.sh")?
	println("Building threefold image at $dest/dockerfile")
	e.node.executor.exec('cd $dest && docker build -t threefold .') or {panic(err)}
	
	return e.image_get("threefold:latest")
}

