module docker
import manifestor



struct DockerEngine{
	mut:
		node manifestor.Node
		sshkeys_allowed []string //all keys here have access over ssh into the machine, when ssh enabled
}

pub fn  new_docker_ngine() DockerEngine{
	return DockerEngine{}
}



//return list of images
fn (mut e DockerEngine) images_list() []DockerImage {

	
	mut res := []DockerImage{}

	for _, image in e.images(){
		res << image
	}
	return res
}

//return list of images
fn (mut e DockerEngine) containers_list() []DockerContainer {
	return []DockerContainer{}
}


//factory class to get a container obj, which can then be filled in and started
fn (mut e DockerEngine) container_new() DockerContainer {
	return DockerContainer{}
}


// helpers

/* map of images */
fn (mut e DockerEngine) images() map[string]DockerImage{
	mut images := e.node.executor.exec("docker images") or {
		println("could not retrieve images, error executing docker images")
		return map[string]DockerImage{}
	}

	mut lines := images.split("\n")
	
	mut res := map[string]DockerImage

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
		mut created := e.node.executor.exec("docker inspect -f '{{ .Created }}' $id") or {
			""
		}

		res[id] = DockerImage{repo: repo, tag: tag, id: id, size: s, created: created}
	}
	return res
}