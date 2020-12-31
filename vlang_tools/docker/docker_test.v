module docker

import builder

fn test_remote_docker() {
	// node := builder.Node{
	// 	name: "remote digitalocean",
	// 	platform: builder.PlatformType.ubuntu,
	// 	executor: builder.ExecutorSSH{
	// 		sshkey: "~/.ssh/id_rsa_test",
	// 		user: "root",
	// 		ipaddr: builder.IPAddress{
	// 			addr: "104.236.53.191",
	// 			port: builder.Port{
	// 				number: 22,
	// 				cat: builder.PortType.tcp
	// 			},
	// 			cat: builder.IpAddressType.ipv4
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
	mut node_args := builder.NodeArguments{
		name: 'test'
		ipaddr: builder.IPAddress{
			addr: ''
		}
		platform: builder.PlatformType.ubuntu
	}
	engine.node = builder.node_get(node_args)
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
