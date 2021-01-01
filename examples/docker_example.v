import rand

import docker

fn docker1() {
	// mut engine := docker.new({node_ipaddr:"node_ipaddr192.168..10:2222",node_name:"myremoteserver"}) or {panic(err)}
	mut engine := docker.new({node_ipaddr:"104.236.53.191:22",node_name:"myremoteserver", user: "root"}) or {panic(err)}
	mut containers := engine.containers_list()
	mut images := engine.images_list()
	println(images)

	mut container := containers[0]
	println(container)
	container.start()
}

fn docker2() {
	mut engine := docker.new({}) or {panic(err)}
	// create new docker
	name := rand.uuid_v4()
	println("creating container : $name")
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
	c.start()
	assert c.status == docker.DockerContainerStatus.up
	export_path := "/tmp/$rand.uuid_v4()"
	c.export(export_path)
	println("deleting container : $name")
	c.delete(true)

	mut found := true
	engine.container_get(name) or {found=false}
	if found{
		panic("container should have been deleted")
	}

	println("creating container : $name")
	engine.container_load(export_path, "$name", "test_image", mut args)

	// should be found again
	found = false

	mut images := engine.images_list()
	for image in images{
		if "$image.repo:$image.tag" == "$name:test_image"{
			found = true
		}
	}

	if !found{
		panic("image should have been found")
	}

	c = engine.container_get(name) or {panic("container should have been loaded")}
	assert "$c.image.repo:$c.image.tag" == "$name:test_image"

	mut newimage_id := c.save2image(c.image.repo, c.image.tag) or {"could not save container to image"}
	
	assert c.image.id == newimage_id

	mut containers := engine.containers_list()
	println(containers)

	// delete (clean)
	println("deleting container : $name")
	
	mut error := false
	c.delete(false) or {error = true}
	if !error{
		panic("should not been able to delete running container")
	}

	c.delete(true) or {panic(err)}
	c.image.delete(false) or {panic(err)}
}

fn main() {
	// docker1()
	docker2()
}
