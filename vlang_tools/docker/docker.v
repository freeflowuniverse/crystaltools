module docker

import rand

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

//get a new docker engine
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
			engine: e
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
		
		mut ports := e.node.executor.exec("docker inspect -f  '{{.Id}} {{.HostConfig.PortBindings}}'  $id") or {
			println(err)
			return []DockerContainer{}
		}
		splitted = ports.split(' ')
		splitted.delete(0)
		ports = splitted.join(' ')
		container.forwarded_ports = e.parse_container_ports(ports)

		mut volumes := e.node.executor.exec("docker inspect -f  '{{.Id}} {{.HostConfig.Binds}}'  $id") or {
			println(err)
			return []DockerContainer{}
		}
		splitted = volumes.split(' ')
		splitted.delete(0)
		volumes = splitted.join(' ')
		container.mounted_volumes = e.parse_container_volumes(volumes)
		res << container
	}
	return res
}

// factory class to get a container obj, which can then be filled in and started
pub fn (mut e DockerEngine) container_new() DockerContainer {
	return DockerContainer{engine: e}
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
	mut image := "$args.image_repo"
	
	if args.image_tag != ""{
		image = image + ":$args.image_tag"
	}

	mut cmd := 'docker run --hostname $args.hostname --name $args.name $ports $mounts -d  -t $image $args.command'
	e.node.executor.exec(cmd) or {panic(err)}

	mut container := e.container_get(args.name) or {panic(err)}
	
	if container.node.executor is builder.ExecutorSSH {
		mut sshkey := container.node.executor.info()['sshkey'] + '.pub'
		mut dest := '/tmp/$rand.uuid_v4()'
		container.node.executor.upload(sshkey, dest)
		container.node.executor.exec("docker cp $dest $container.id:$dest && docker start $container.id && docker exec $container.id sh -c 'cat $dest >> ~/.ssh/authorized_keys'")
	}
	return container
}

pub fn (mut e DockerEngine) container_get(name_or_id string) ?DockerContainer {
	for c in e.containers_list(){
		if c.name == name_or_id || c.id == name_or_id{
			return c
		}
	}
	return error("Cannot find container with name $name_or_id")
}

// import a container into an image, run docker container with it
// image_repo examples ['myimage', 'myimage:latest']
// if DockerContainerCreateArgs contains a name, container will be created and restarted
pub fn (mut e DockerEngine) container_load(path string, image_repo string, image_tag string, mut args DockerContainerCreateArgs) ?DockerContainer {
	mut image := "$image_repo"
	
	if image_tag != "" {
		image = image + ":$image_tag"
	}
	e.node.executor.exec('docker import  $path $image') or {panic(err)}
	// make sure we start from loaded image
	args.command = "/bin/bash"
	args.image_repo = image_repo
	args.image_tag = image_tag
	return e.container_create(args)
}


fn (mut e DockerEngine) parse_container_ports(ports string) []string {
	mut str := ports.trim_right("]").trim_left("map[").trim(" ").replace("]] ", " ").replace("]]", " ").replace("[map[HostIp: HostPort:", "")
	mut res := []string{}
	if str == "" {
		return res
	}
	splitted := str.split(" ")
	for element in splitted{
		ss := element.split(":")
		dest := ss[1]
		src_splitted := ss[0].split("/")
		src := src_splitted[0]
		protocol := src_splitted[1]
		res << "$src:$dest/$protocol"
	}
	return res
}

fn (mut e DockerEngine) parse_container_volumes(volumes string) []string {
	res := volumes.trim_right("]").trim_left("[").trim(" ").trim(" ")
	if res == "" {
		return []string{}
	}
	return res.split(" ")
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


//name is repo:tag or image id
pub fn (mut e DockerEngine) image_get(name_or_id string) ?DockerImage {
	images_list := e.images_list()
	
	mut splitted := name_or_id.split(":")
	mut repo := ""
	mut tag := ""
	mut id := ""

	if splitted.len > 1{
		repo = splitted[0]
		tag = splitted[1]
	}else if splitted.len == 1{
		repo = splitted[0]
		id = splitted[0]
	}

	for i in e.images_list(){
		if (i.repo == repo && i.tag == tag) || i.id == id{
			return i
		}
	}
	return error("Cannot find image  $name_or_id")
}

//reset all images & containers, CAREFUL!
pub fn (mut e DockerEngine) reset_all() {
	e.node.executor.exec("docker container rm -f $(docker container ls -aq)") or {}
	e.node.executor.exec("docker image prune -a -f") or {panic(err)}
	e.node.executor.exec("docker builder prune -a -f") or {panic(err)}

}