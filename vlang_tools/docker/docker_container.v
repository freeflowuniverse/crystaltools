module docker

import builder
import rand

enum DockerContainerStatus {
	up
	down
	restarting
	paused
	dead
	created
}

// need to fill in what is relevant
struct DockerContainer {
	id          	string
	name        	string
	hostname    	string
	created    		string
	ssh_enabled 	bool // if yes make sure ssh is enabled to the container
	info        	DockerContainerInfo
	ports       	[]string
	forwarded_ports	[]string
	mounted_volumes	[]DockerContainerVolume
pub mut:
	node        builder.Node
	image       DockerImage
	status      DockerContainerStatus
}

struct DockerContainerInfo {
	ipaddr builder.IPAddress
}

struct DockerContainerVolume{
	src 	string
	dest	string
}

pub struct DockerContainerCreateArgs{
	name        	string
	hostname    	string
	forwarded_ports	[]string // ["80:9000/tcp", "1000, 10000/udp"]
	mounted_volumes	[]string // ["/root:/root", ]
	image_repo      string
}


// create/start container (first need to get a dockercontainer before we can start)
pub fn (mut container DockerContainer) start() ?string {
	mut cmd := ''
	if container.node.executor is builder.ExecutorSSH {
		mut sshkey := container.node.executor.info()['sshkey'] + '.pub'
		mut dest := '/tmp/$rand.uuid_v4()'
		container.node.executor.upload(sshkey, dest)
		cmd = cmd +
			"docker cp $dest $container.id:$dest && docker start $container.id && docker exec $container.id sh -c 'cat $dest >> ~/.ssh/authorized_keys'"
	} else {
		cmd = 'docker start $container.id'
	}
	println(cmd)
	return container.node.executor.exec(cmd)
}

// delete docker container
pub fn (mut container DockerContainer) halt() ?string {
	x := container.node.executor.exec('docker stop $container.id') or {return err}
	container.status = DockerContainerStatus.down
	return x
}

// delete docker container
pub fn (mut container DockerContainer) delete(force bool) ?string {
	if force {
		return container.node.executor.exec('docker rm -f $container.id')
	}
	return container.node.executor.exec('docker rm $container.id')
}

// save the docker container to image
pub fn (mut container DockerContainer) save2image(image_id string) ?string {
	return container.node.executor.exec('docker commit $container.id $image_id')
}

// export docker to tgz
pub fn (mut container DockerContainer) export(path string) ?string {
	return container.node.executor.exec('docker export $container.id > $path')
}

// when importing docker get's restarted
pub fn (mut container DockerContainer) load(path string) ?string {
	return container.node.executor.exec('docker import  $path')
}

// open ssh shell to the cobtainer
pub fn (mut container DockerContainer) ssh_shell() ? {
}

// return the builder.node class which allows to remove executed, ...
pub fn (mut container DockerContainer) node_get() ?builder.Node {
	return container.node
}
