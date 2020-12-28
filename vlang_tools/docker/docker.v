module docker
import manifestor



struct DockerEngine{
	mut:
		executor Node
		sshkeys_allowed []string //all keys here have access over ssh into the machine, when ssh enabled
}


//return list of images
fn (mut e DockerEngine) images_get() []DockerImage {
	//
}

//return list of images
fn (mut e DockerEngine) containers_get() []DockerContainer {
	//
}


//factory class to get a container obj, which can then be filled in and started
fn (mut e DockerEngine) container_new() DockerContainer {
	//
}
