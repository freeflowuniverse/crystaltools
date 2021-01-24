module docker

C=```
# FROM alpine:3.13
FROM $base
RUN rm  -rf /tmp/* /var/cache/apk/*
RUN apk add --no-cache redis && apk add --no-cache dumb-init 
RUN apk add --no-cache curl libssh2

RUN echo 'nameserver 8.8.8.8' > '/etc/resolv.conf'

# add openssh and clean
RUN apk add --no-cache openssh && rm  -rf /tmp/* /var/cache/apk/*

# add entrypoint script
ADD boot.sh /usr/local/bin

#make sure we get fresh keys
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key
RUN chmod 770 /usr/local/bin/boot.sh

RUN apk add --no-cache mc htop rsync

@if redis_enable {
RUN apk add --no-cache redis
EXPOSE 6379
}

EXPOSE 22

RUN echo 'THREEFOLD BASE DEV ENV WELCOMES YOU' > /etc/motd

// ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/usr/local/bin/boot.sh"]

```

BOOT=```
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
ln -s /myhost/authorized_keys /root/.ssh/authorized_keys
# chmod 600 /root/.ssh/authorized_keys
passwd -u root #to get pam to work

#no -D because then goes to background
/usr/sbin/sshd

@if redis_enable {
redis-server /etc/redis.conf  --daemonize yes
}


sh
```

//TODO: generate  default ssh key which we will use everwhere as default key to get started
pub sshkey_priv=```
```

pub sshkey_pub=```
```


//build ssh enabled alpine docker image
//has default ssh key in there
pub fn (mut e DockerEngine) builder_build() ?DockerImage {

	//TODO: create temporary directory
	// store the docker file & the boot.sh file
	// run the docker builder
	// return the image which has been build

	//use template engine to get the base in
	base = "alpine:3.13"
	redis_enable = false

	//template engine/write files ... (use variables)


}


//if docker image for builder not build yet (locally, then do so) 
//start a container with the image of the builder
//do a test that ssh is working with predefined key
pub fn (mut e DockerEngine) builder_container_get(name:string) ?DockerContainer {


}

