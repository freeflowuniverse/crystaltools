module docker

import rand
import os


// build ssh enabled alpine docker image
// has default ssh key in there
pub fn (mut e DockerEngine) build() ?DockerImage{
	
	mut dest := '/tmp/$rand.uuid_v4()'
	println("Creating temp dir $dest")
	e.node.executor.exec("mkdir $dest")?
	mut currpath := @FILE.split("/")
	currpath.pop()
	mut templates :=  os.join_path(currpath.join("/"), "templates")
	
	base := "alpine:3.13"
	redis_enable := false
	mut dockerfile_path := "$templates/dockerfile"

	// dockerfile :=  $tmpl("dockerfile")
	mut dockerfile := os.read_file(dockerfile_path) or {panic(err)}
	dockerfile = dockerfile.replace("\$base", base).replace("redis_enable", "$redis_enable")
	
	e.node.executor.exec("echo '$dockerfile' > $dest/dockerfile")?
	e.node.executor.upload("$templates/boot.sh", "$dest/boot.sh")?
	println("Building threefold image at $dest/dockerfile")
	e.node.executor.exec('cd $dest && docker build -t threefold .') or {panic(err)}
	
	return e.image_get("threefold:latest")
}

//if docker image for builder not build yet (locally, then do so) 
//start a container with the image of the builder
//do a test that ssh is working with predefined key
// pub fn (mut e DockerEngine) builder_container_get(name:string) ?DockerContainer {


// }
