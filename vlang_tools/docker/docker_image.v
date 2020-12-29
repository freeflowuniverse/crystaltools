module docker

import manifestor

pub struct DockerImage{
	pub mut:
		repo string
		tag string
		id string
		size f64
		created string
		node manifestor.Node
}


//delete docker image
fn (mut image DockerImage) delete(id string) ? {
	
}


//export docker image to tar.gz
fn (mut image DockerImage) export( path string) ? {
	
}

//import docker image back into the local env
fn (mut image DockerImage) imports( path string) ?DockerImage {
	
}
