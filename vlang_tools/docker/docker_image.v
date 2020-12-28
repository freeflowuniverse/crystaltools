module docker


struct DockerImage{

}


//delete docker image
fn (mut image DockerImage) delete() ? {
	
}


//export docker image to tar.gz
fn (mut image DockerImage) export( path string) ? {
	
}

//import docker image back into the local env
fn (mut image DockerImage) import( path string) ?DockerImage {
	
}
