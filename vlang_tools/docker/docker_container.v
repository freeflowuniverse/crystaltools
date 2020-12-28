module docker
import manifestor

//need to fill in what is relevant
struct DockerContainer{
	name string
	image_url string
	ssh_enabled bool //if yes make sure ssh is enabled to the container
	info DockerContainerInfo
}

struct DockerContainerInfo{
	ipaddr manifestor.IpAddress

	
}


//create/start container (first need to get a dockercontainer before we can start)
fn (mut container DockerContainer) start() ? {
	
}


//delete docker container
fn (mut container DockerContainer) halt() ? {
	
}


//delete docker container
fn (mut container DockerContainer) delete() ? {
	
}


//save the docker container to image
fn (mut container DockerContainer) save2image( path string) ? {
	
}



//export docker to tgz
fn (mut container DockerContainer) export( path string) ? {
	//use docker_image.export...
	
}


//when importing docker get's restarted
fn (mut container DockerContainer) import( path string) ? {
	//use docker_image.import...
	
}

//open ssh shell to the cobtainer
fn (mut container DockerContainer) ssh_shell() ? {
	
}


//return the manifestor.node class which allows to remove executed, ...
fn (mut container DockerContainer) node_get() ?manifestor.Node {
	
}



