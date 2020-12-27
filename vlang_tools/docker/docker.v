module docker
// import manifestor

struct ExecutorLocal {
	pub mut:
		name string = "local"
}

struct ExecutorSSH {
	pub mut:
		name string = "ssh"
}


fn (e ExecutorLocal) images_list() string {
	return e.name
}

fn (e ExecutorSSH) images_list() string {
	return e.name
}


// type Executor = ExecutorLocal | ExecutorSSH

struct DockerEngine<T> {
	name string = "nothing"
	mut:
		executor T
}

fn new<T>() DockerEngine<T> {
    de := DockerEngine<T>{}
	return de
}

fn (mut e DockerEngine<ExecutorLocal>) images_list() string {
	return e.executor.images_list()
}

fn (mut e DockerEngine<ExecutorSSH>) images_list() string {
	return e.executor.images_list()
}

fn (mut e DockerEngine<T>) images_list() string {
	return e.executor.images_list()
}


// struct Docker {
// 	name string
// }


// //list all image names
// fn (mut engine DockerEngine) images_list() string {
// 	 match engine.executor {
//         ExecutorSSH { engine.executor.image_list() }
//         ExecutorLocal { engine.executor.image_list() }
//     }
// 	// return engine.executor.name
// }

//list all image names



// fn (engine DockerEngine<ExecutorLocal>) images_list() string {
// 	return engine.executor.name
// }

// fn (engine DockerEngine<ExecutorSSH>) images_list() string {
// 	return engine.executor.name
// }

// fn get (executor Executor) DockerEngine {
// 	return DockerEngine{executor:executor}
// }

