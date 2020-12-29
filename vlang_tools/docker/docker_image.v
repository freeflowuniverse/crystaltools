module docker


pub struct DockerImage{
	pub mut:
		repo string
		tag string
		id string
		size f64
		created string
}


//delete docker image
fn (mut image DockerImage) delete() ? {
	
}


//export docker image to tar.gz
fn (mut image DockerImage) export( path string) ? {
	
}

//import docker image back into the local env
fn (mut image DockerImage) imports( path string) ?DockerImage {
	
}
