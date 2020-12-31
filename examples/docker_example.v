import rand

import docker

fn docker1() {
	//get a local docker instance
//	mut engine := docker.new({node_ipaddr:"node_ipaddr192.168..10:2222",node_name:"myremoteserver"}) or {panic(err)}
	mut engine := docker.new({node_ipaddr:"104.236.53.191:22",node_name:"myremoteserver", user: "root"}) or {panic(err)}
	mut containers := engine.containers_list()
	mut images := engine.images_list()
	println(images)

	// mut container := containers[0]
	// println(container)
	// container.start()
}

fn docker2() {
	mut engine := docker.new({}) or {panic(err)}
	// create new docker
	name := rand.uuid_v4()
	println(name)
	mut args := docker.DockerContainerCreateArgs{
		name: name,
		hostname: name,
		mounted_volumes: ["/tmp:/tmp"],
		forwarded_ports: [],
		image_repo: "ubuntu"
	}

	// create new container
	mut c := engine.container_create(args) or {panic(err)}
	assert c.status == docker.DockerContainerStatus.up
	c.halt()
	assert c.status == docker.DockerContainerStatus.down
	c.delete(false)
	mut found := true
	engine.container_get(name) or {found=false}
	if found{
		panic("container should have been deleted")
	}

	mut containers := engine.containers_list()
	mut images := engine.images_list()
	
	println(containers)
	println(images)
	
}
fn main() {
	// docker1()
	docker2()
}
