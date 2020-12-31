module docker

import builder

struct DockerEngine {
pub mut :
	node            builder.Node
	sshkeys_allowed []string // all keys here have access over ssh into the machine, when ssh enabled
}


pub struct DockerNodeArguments {
	sshkeys_allowed []string // all keys here have access over ssh into the machine, when ssh enabled
	node_ipaddr   string
	node_name     string
	user	      string
}

//get a new docker image
// to use docker.new() -> returns DockerEngine for local machine
// to use docker.new(node_ipaddr:"node_ipaddr192.168..10:2222",node_name:"myremoteserver") -> returns DockerEngine for a remote machine, ssh-agent needs to be loaded
// to use docker.new(node_ipaddr:"192.168..10",node_name:"myremoteserver") -> returns DockerEngine for a remote machine on default ssh port 22
pub fn new(args DockerNodeArguments) ?DockerEngine {
	mut node_name := args.node_ipaddr
	if node_name==""{
		if  args.node_ipaddr == ""{
			node_name = "localnode"
		}else{
			return error("node name cannot be empty if ipaddress is not localhost. ")
		}
	}

	mut node := builder.node_get(ipaddr:args.node_ipaddr,name:node_name, user: args.user)?
	mut de := DockerEngine{node:node,sshkeys_allowed:args.sshkeys_allowed}
	de.init()
	return de
}

// return list of images
pub fn (mut e DockerEngine) images_list() []DockerImage {
	mut res := []DockerImage{}
	mut images := e.node.executor.exec('docker images') or {
		println(err)
		return []DockerImage{}
	}
	mut lines := images.split('\n')
	for line in lines[1..lines.len] {
		info := line.split_by_whitespace()
		mut repo := info[0]
		mut tag := info[1]
		if tag == '<none>' {
			tag = ''
		}
		if repo == '<none>' {
			repo = ''
		}
		id := info[2]
		size := info[info.len - 1]
		mut s := 0.0
		if size.ends_with('GB') {
			s = size.replace('GB', '').f64() * 1024 * 1024 * 1024
		} else if size.ends_with('MB') {
			s = size.replace('MB', '').f64() * 1024 * 1024
		}
		mut details := e.node.executor.exec("docker inspect -f '{{ .Id }} {{ .Created }}' $id") or {
			panic(err)
		}
		splitted := details.split(' ')
		res << DockerImage{
			repo: repo
			tag: tag
			id: splitted[0]
			size: s
			created: splitted[1]
			node: e.node
		}
	}
	return res
}

pub fn (mut e DockerEngine) init() {
	// docker version

}

// return list of images
pub fn (mut e DockerEngine) containers_list() []DockerContainer {
	mut res := []DockerContainer{}
	mut images := e.images_list()
	mut containers := e.node.executor.exec('docker ps -a') or {
		println('could not retrieve containers, error executing docker ps -a')
		return []DockerContainer{}
	}
	if containers == '' {
		return res
	}
	
	mut lines := containers.split('\n')
	for line in lines[1..lines.len] {
		info := line.split_by_whitespace()
		mut id := info[0]
		mut name := info[info.len - 1]
		
		details := e.node.executor.exec("docker inspect -f  '{{.Id}} {{.Created }} {{.Image}}'  $id") or {
			println('could not retrieve container info')
			return []DockerContainer{}
		}
		mut splitted := details.split(' ')
		mut container := DockerContainer{
			id: splitted[0]
			created: splitted[1]
			name: name
			node: e.node
		}
		for image in images {
			if image.id == splitted[2] {
				container.image = image
				break
			}
		}
		

		mut state := e.node.executor.exec("docker inspect -f  '{{.Id}} {{.State}}'  $id") or {
			println(err)
			return []DockerContainer{}
		}
		splitted = state.split(' ')
		splitted.delete(0)
		state = splitted.join(' ')
		container.status = e.parse_container_state(state)
		res << container
	}
	return res
}

// factory class to get a container obj, which can then be filled in and started
pub fn (mut e DockerEngine) container_new() DockerContainer {
	return DockerContainer{}
}

fn (mut e DockerEngine) parse_container_state(state string) DockerContainerStatus {
	if 'Dead:true' in state {
		return DockerContainerStatus.dead
	}
	if 'Paused:true' in state {
		return DockerContainerStatus.paused
	}
	if 'Restarting:true' in state {
		return DockerContainerStatus.restarting
	}
	if 'Running:true' in state {
		return DockerContainerStatus.up
	}
	if 'Status:created' in state {
		return DockerContainerStatus.created
	}
	return DockerContainerStatus.down
}


pub fn (mut e DockerEngine) container_create(args DockerContainerCreateArgs) ?DockerContainer {
	mut ports := ""
	mut mounts := ""

	for port in args.forwarded_ports{
		ports = ports + "-p $port "
	}

	for mount in args.mounted_volumes{
		mounts += "-v $mount "
	}
	e.node.executor.exec('docker run --hostname $args.hostname --name $args.name $ports $mounts -d -t $args.image_repo ') or {println(err)}
	return e.container_get(args.name)
}

pub fn (mut e DockerEngine) container_get(name_or_id string) ?DockerContainer {
	for c in e.containers_list(){
		if c.name == name_or_id || c.id == name_or_id{
			return c
		}
	}
	return error("")
}
