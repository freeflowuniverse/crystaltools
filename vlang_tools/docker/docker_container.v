module docker
import manifestor

enum DockerContainerStatus {up down restarting paused dead created}

//need to fill in what is relevant
struct DockerContainer{
	id string
	name string
	created string
	
	ssh_enabled bool //if yes make sure ssh is enabled to the container
	info DockerContainerInfo
	ports []string
	mut:
		image DockerImage
		status DockerContainerStatus
	pub mut:
		node manifestor.Node
}

struct DockerContainerInfo{
	ipaddr manifestor.IPAddress

	
}


//create/start container (first need to get a dockercontainer before we can start)
fn (mut container DockerContainer) start() ?string {
	return container.node.executor.exec("docker start $container.id")
}


//delete docker container
fn (mut container DockerContainer) halt() ?string {
	return container.node.executor.exec("docker stop $container.id") 
}


//delete docker container
fn (mut container DockerContainer) delete(force bool) ?string {
	if force{
		return container.node.executor.exec("docker rm -f $container.id")
		
	}
	return container.node.executor.exec("docker rm $container.id")
}

//save the docker container to image
fn (mut container DockerContainer) save2image( image_id string) ?string {
	return container.node.executor.exec("docker commit $container.id $image_id")
}



//export docker to tgz
fn (mut container DockerContainer) export( path string) ?string {
	return container.node.executor.exec("docker export $container.id > $path")
}


//when importing docker get's restarted
fn (mut container DockerContainer) load ( path string) ?string {
	return container.node.executor.exec("docker import  $path")
}

//open ssh shell to the cobtainer
fn (mut container DockerContainer) ssh_shell() ? {
	
}


//return the manifestor.node class which allows to remove executed, ...
fn (mut container DockerContainer) node_get() ?manifestor.Node {
	return container.node
}



