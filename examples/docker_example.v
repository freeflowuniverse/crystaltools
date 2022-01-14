import rand
import despiegk.crystallib.builder
import despiegk.crystallib.docker

fn docker1()? {
	sshkey := "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/9RNGKRjHvViunSOXhBF7EumrWvmqAAVJSrfGdLaVasgaYK6tkTRDzpZNplh3Tk1aowneXnZffygzIIZ82FWQYBo04IBWwFDOsCawjVbuAfcd9ZslYEYB3QnxV6ogQ4rvXnJ7IHgm3E3SZvt2l45WIyFn6ZKuFifK1aXhZkxHIPf31q68R2idJ764EsfqXfaf3q8H3u4G0NjfWmdPm9nwf/RJDZO+KYFLQ9wXeqRn6u/mRx+u7UD+Uo0xgjRQk1m8V+KuLAmqAosFdlAq0pBO8lEBpSebYdvRWxpM0QSdNrYQcMLVRX7IehizyTt+5sYYbp6f11WWcxLx0QDsUZ/J"

	// mut node := builder.node_get(ipaddr: "", name: "test") ?

	mut engine := docker.new(sshkeys_allowed:[sshkey])?
	engine.reset_all()
	// mut containers := engine.containers_list()
	// println(containers)
	// mut images := engine.images_list()
	// assert containers.len == 0
	// assert images.len == 0

	// name := rand.uuid_v4()
	// println('creating container : $name')
	// mut args := docker.DockerContainerCreateArgs{
	// 	name: name
	// 	hostname: name
	// 	mounted_volumes: ['/tmp:/tmp']
	// 	forwarded_ports: []
	// 	image_repo: 'ubuntu'
	// }

	// // create new container
	// mut c := engine.container_create(args) or { panic(err) }
	// assert c.status == docker.DockerContainerStatus.up
	// c.halt() or { panic(err) }
	// assert c.status == docker.DockerContainerStatus.down
	// c.start() or { panic(err) }
	// assert c.status == docker.DockerContainerStatus.up
	// export_path := '/tmp/$rand.uuid_v4()'
	// c.export(export_path) or { panic(err) }
	// println('deleting container : $name')
	// c.delete(true) or { panic(err) }
}

// fn docker2()? {
// 	sshkey := "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/9RNGKRjHvViunSOXhBF7EumrWvmqAAVJSrfGdLaVasgaYK6tkTRDzpZNplh3Tk1aowneXnZffygzIIZ82FWQYBo04IBWwFDOsCawjVbuAfcd9ZslYEYB3QnxV6ogQ4rvXnJ7IHgm3E3SZvt2l45WIyFn6ZKuFifK1aXhZkxHIPf31q68R2idJ764EsfqXfaf3q8H3u4G0NjfWmdPm9nwf/RJDZO+KYFLQ9wXeqRn6u/mRx+u7UD+Uo0xgjRQk1m8V+KuLAmqAosFdlAq0pBO8lEBpSebYdvRWxpM0QSdNrYQcMLVRX7IehizyTt+5sYYbp6f11WWcxLx0QDsUZ/J"
// 	mut engine := docker.new(sshkeys_allowed:[sshkey])?
// 	engine.reset_all()
// 	mut containers := engine.containers_list()
// 	mut images := engine.images_list()
// 	assert containers.len == 0
// 	assert images.len == 0

// 	// create new docker
// 	name := rand.uuid_v4()
// 	println('creating container : $name')
// 	mut args := docker.DockerContainerCreateArgs{
// 		name: name
// 		hostname: name
// 		mounted_volumes: ['/tmp:/tmp']
// 		forwarded_ports: []
// 		image_repo: ''
// 	}

// 	// create new container
// 	mut c := engine.container_create(args) or { panic(err) }
// 	assert c.image.repo == 'threefold'
// 	assert c.status == docker.DockerContainerStatus.up
// 	c.halt() or { panic(err) }
// 	assert c.status == docker.DockerContainerStatus.down
// 	c.start() or { panic(err) }
// 	assert c.status == docker.DockerContainerStatus.up
// 	export_path := '/tmp/$rand.uuid_v4()'
// 	c.export(export_path) or { panic(err) }
// 	println('deleting container : $name')
// 	c.delete(true) or { panic(err) }

// 	mut found := true
// 	engine.container_get(name) or { found = false }
// 	if found {
// 		panic('container should have been deleted')
// 	}

// 	println('loading container : $name')
// 	args = docker.DockerContainerCreateArgs{
// 		name: name
// 		hostname: name
// 		mounted_volumes: ['/tmp:/tmp']
// 		forwarded_ports: []
// 		image_repo: name
// 		image_tag: 'test_image'
// 		command: '/usr/local/bin/boot.sh' // important for threefold image
// 	}
// 	engine.container_load(export_path, mut args) or { panic(err) }

// 	// should be found again
// 	found = false

// 	images = engine.images_list()
// 	for image in images {
// 		if '$image.repo:$image.tag' == '$name:test_image' {
// 			found = true
// 		}
// 	}

// 	if !found {
// 		panic('image should have been found')
// 	}

// 	c = engine.container_get(name) or { panic('container should have been loaded') }
// 	assert '$c.image.repo:$c.image.tag' == '$name:test_image'

// 	mut newimage_id := c.save2image(c.image.repo, c.image.tag) or {
// 		'could not save container to image'
// 	}

// 	assert c.image.id == newimage_id

// 	containers = engine.containers_list()
// 	println(containers)

// 	println('deleting container : $name')

// 	mut error := false
// 	c.delete(false) or { error = true }
// 	if !error {
// 		panic('should not been able to delete running container')
// 	}

// 	c.delete(true) or { panic(err) }
// 	c.image.delete(false) or { panic(err) }
// }

fn main() {
	docker1() or { panic(err)}
	// docker2() or { panic(err)}
}
