module docker

fn test_docker1() {
	// assert json.encode(obj)== json.encode(tocompare)



	mut engine := new<ExecutorSSH>()
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
