module docker
import manifestor



struct DockerEngine{
	mut:
		node manifestor.Node
		sshkeys_allowed []string //all keys here have access over ssh into the machine, when ssh enabled
}

fn  new_docker_ngine() DockerEngine{
	return DockerEngine{}
}

//return list of images
fn (mut e DockerEngine) images_list() []DockerImage {
	mut images := e.node.executor.exec("docker images") or {
		println("could not retrieve images, error executing docker command")
		return []DockerImage{}
	}

	mut lines := images.split("\n")
	
	mut res := []DockerImage{}

	for line in lines[1 .. lines.len-1]{
		info := line.split_by_whitespace()
		mut repo := info[0]
		mut tag := info[1]
		
		if tag == "<none>"{
			tag = ""
		}

		if repo == "<none>"{
			repo = ""
		}

		id := info[2]
		size := info[info.len-1]
		
		mut s := 0.0
		if size.ends_with("GB"){
			s = size.replace("GB", "").f64() * 1024 * 1024 * 1024
		}else if size.ends_with("MB"){
			s = size.replace("MB", "").f64() * 1024 * 1024
		}
		res << DockerImage{repo: repo, tag: tag, id: id, size: s}
	}

	return res
}

//return list of images
fn (mut e DockerEngine) containers_get() []DockerContainer {
	return []DockerContainer{}
}


//factory class to get a container obj, which can then be filled in and started
fn (mut e DockerEngine) container_new() DockerContainer {
	return DockerContainer{}
}


// helpers

fn split(text string) []string{
	mut splitted := text.split(" ")
	mut res := []string{}

	for item in splitted{
		if item != ""{
			res << item
		}
	}

	return res
}