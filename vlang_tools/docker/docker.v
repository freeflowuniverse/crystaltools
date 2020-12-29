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

	mut images := e.node.executor.exec("docker images") or {
		println("could not retrieve images, error executing docker images")
		return []DockerImage{}
	}

	mut lines := images.split("\n")

	for line in lines[1 .. lines.len]{
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
		mut details := e.node.executor.exec("docker inspect -f '{{ .Id }} {{ .Created }}' $id") or {
			""
		}

		splitted:= details.split(" ")
		
		res << DockerImage{repo: repo, tag: tag, id: splitted[0], size: s, created: splitted[1], node: e.node}
	}

	return res
}

//return list of images
fn (mut e DockerEngine) containers_list() []DockerContainer {
	mut res := []DockerContainer{}
	mut images := e.images_list()

	mut containers := e.node.executor.exec("docker ps -a") or {
		println("could not retrieve containers, error executing docker ps -a")
		return []DockerContainer{}
	}

	if containers == ""{
		return res
	}
	
	mut lines := containers.split("\n")
	for line in lines[1 .. lines.len]{
		info := line.split_by_whitespace()
		mut id := info[0]
		mut name := info[info.len -1]
		details := e.node.executor.exec("docker inspect -f  '{{.Id}} {{.Created }} {{.Image}}'  $id") or {
			println("could not retrieve container info")
			return []DockerContainer{}
		}
		// {{.State}} {{.Path}} {{.Args}}
		mut splitted := details.split(" ")
		mut container := DockerContainer{
			id: splitted[0]
			created: splitted[1]
			name: name
		}

		for image in images{
			if image.id == splitted[2]{
				container.image = image
				break
			}
		}

		mut state := e.node.executor.exec("docker inspect -f  '{{.Id}} {{.State}}'  $id") or {
			println("could not retrieve containers info")
			return []DockerContainer{}
		}

		splitted = state.split(" ")
		splitted.delete(0)
		state = splitted.join(" ")
		container.status = e.parse_container_state(state)
		res << container
	}

	return res
}


//factory class to get a container obj, which can then be filled in and started
fn (mut e DockerEngine) container_new() DockerContainer {
	return DockerContainer{}
}


fn (mut e DockerEngine) parse_container_state(state string) DockerContainerStatus{
	if "Dead:true" in state{
		return DockerContainerStatus.dead
	}

	if "Paused:true" in state{
		return DockerContainerStatus.paused
	}

	if "Restarting:true" in state{
		return DockerContainerStatus.restarting
	}

	if "Running:true" in state{
		return DockerContainerStatus.up
	}

	if "Status:created" in state{
		return DockerContainerStatus.created
	}

	return DockerContainerStatus.down
}