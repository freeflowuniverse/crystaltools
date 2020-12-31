import docker

fn docker1() {
	//get a local docker instance
	mut engine := docker.new({node_ipaddr:"node_ipaddr192.168..10:2222",node_name:"myremoteserver"}) or {panic(err)}
	println(engine.images_list())
	mut containers := engine.containers_list()
	mut container := containers[0]
	println(container)
	container.start()
}

// fn docker2() {
// 	mut engine := docker.new_docker_engine()
// 	engine.node = builder.node_get(name: 'test')
// 	println(engine.images_list())
// 	mut containers := engine.containers_list()
// 	mut container := containers[0]
// 	println(container)
// 	container.start()
// }
fn main() {
	docker1()
	// docker2()
}
