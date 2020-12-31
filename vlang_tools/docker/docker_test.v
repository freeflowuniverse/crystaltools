module docker
import manifestor

fn test_remote_docker(){
		// node := manifestor.Node{
	// 	name: "remote digitalocean",
	// 	platform: manifestor.PlatformType.ubuntu,
	// 	executor: manifestor.ExecutorSSH{
	// 		sshkey: "~/.ssh/id_rsa_test",
	// 		user: "root",
	// 		ipaddr: manifestor.IPAddress{
	// 			addr: "104.236.53.191",
	// 			port: manifestor.Port{
	// 				number: 22,
	// 				cat: manifestor.PortType.tcp
	// 			},
	// 			cat: manifestor.IpAddressType.ipv4
	// 		}
	// 	}
	// }

	// engine.node = node

	// // println(engine.images_list())
	// mut containers := engine.containers_list()
	// println(containers)
	
	// mut container := containers[0]
	// println(container)
	// container.start() or {panic(err)}
}
fn test_docker1() {

	mut engine := new_docker_ngine()

	mut node_args := manifestor.NodeArguments{name: "test", ipaddr: manifestor.IPAddress{addr: ""}, platform: manifestor.PlatformType.ubuntu}
	engine.node = manifestor.node_get(node_args)

	println(engine.images_list())
	mut containers := engine.containers_list()

	mut container := containers[0]
	println(container)
	container.start()




	// mut engine2 := DockerEngine<ExecutorLocal>{}
	// engine2.executor.name = "aaa"
	// println(engine2.images_list())


	// mut engine := get(Executor(ExecutorSSH{}))
	// println(engine)
	// println(engine.images_list())
	// mut engine2 := get(ExecutorLocal{})
	// println(engine2.images_list())

}
