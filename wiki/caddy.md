# Run Caddy Server


## Install Required Software

```bash
# prerequisits
apt install redis mc rsync git -y
apt install gcc make -y
apt install libssl-dev -y
curl https://raw.githubusercontent.com/freeflowuniverse/crystaltools/development/install.sh | bash

# get main repo's

mkdir -p /root/code/github/threefoldfoundation/
cd -p /root/code/github/threefoldfoundation/
git clone https://github.com/threefoldfoundation/info_threefold

# to test 
source /root/env.sh
cd /root/code/github/threefoldfoundation/wiki_config
publishtools develop

#install caddy
# apt install -y debian-keyring debian-archive-keyring apt-transport-https -y
# curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo tee /etc/apt/trusted.gpg.d/caddy-stable.asc
# curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
# apt update -y
# apt install caddy -y

#install caddy
cd /tmp
apt install -y debian-keyring debian-archive-keyring apt-transport-https golang -y
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/xcaddy/gpg.key' | sudo tee /etc/apt/trusted.gpg.d/caddy-xcaddy.asc
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/xcaddy/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-xcaddy.list
apt update
apt install xcaddy
xcaddy build --with github.com/baldinof/caddy-supervisor
cp xcaddy /usr/bin/xcaddy

```

## caddy file

```python
# The Caddyfile is an easy way to configure your Caddy web server.
#
# Unless the file starts with a global options block, the first
# uncommented line is always the address of your site.
#
# To use your own domain name (with automatic HTTPS), first make
# sure your domain's A/AAAA DNS records are properly pointed to
# this machine's public IP, then replace ":80" below with your
# domain name.
{
  # Must be in global options
  supervisor {
    publishtools develop {
      dir /root/code/info_threefold/wiki_config
    
      restart_policy always 
      
      redirect_stdout file /var/log/publish.log       # redirect command stdout to a file. Default to caddy `stdout`
      redirect_stderr file /var/log/publish-error.log # redirect command stderr to a file. Default to caddy `stderr`
      
      termination_grace_period 3s # default to '10s', amount of time to wait for application graceful termination before killing it
      
    }    
  }
}


library.threefold.me {
	# Set this path to your site's directory.
	# root * /usr/share/caddy

	# Enable the static file server.
	# file_server

	# Another common task is to set up a reverse proxy:
	reverse_proxy localhost:9998

	# Or serve a PHP site through php-fpm:
	# php_fastcgi localhost:9000
}

# Refer to the Caddy docs for more information:
# https://caddyserver.com/docs/caddyfile


```

## Edit/Copy Caddy File

edit

```
code-insiders /tmp/Caddyfile
```

```
scp root@164.90.195.7:/etc/caddy/Caddyfile /tmp/Caddyfile
scp /tmp/Caddyfile root@164.90.195.7:/etc/caddy/Caddyfile && ssh root@164.90.195.7  'cd /etc/caddy && caddy reload'
```

## pull repos & reload

```
ssh -A root@164.90.195.7  'cd /root/code/info_threefold/wiki_config && publishtools pull -r && cd /etc/caddy && caddy reload'
```

### see log

```
ssh root@164.90.195.7 'tail -f /var/log/publish.log'
```