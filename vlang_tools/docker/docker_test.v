module docker
import manifestor

fn test_docker1() {
	// assert json.encode(obj)== json.encode(tocompare)



	mut engine := new_docker_ngine()

	mut node_args := manifestor.NodeArguments{name: "test", ipaddr: manifestor.IPAddress{addr: ""}, platform: manifestor.PlatformType.ubuntu}
	engine.node = manifestor.node_get(node_args)

	println(engine.images_list())

	// mut engine2 := DockerEngine<ExecutorLocal>{}
	// engine2.executor.name = "aaa"
	// println(engine2.images_list())


	// mut engine := get(Executor(ExecutorSSH{}))
	// println(engine)
	// println(engine.images_list())
	// mut engine2 := get(ExecutorLocal{})
	// println(engine2.images_list())

	panic("a")
}
