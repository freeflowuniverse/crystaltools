module manifestor

pub struct Node {
	name string = "mymachine"	
	executor 		executor.ExecutorLocal
	mut:
		platformtype 	PlatformType	
}

pub enum PlatformType { unknown osx ubuntu alpine }

//get the node instance
pub fn new() Node{
	mut node := Node{}
	mut node.executor := ExecutorLocal{}
	node.executor.platform_load()
	return node
}

fn (mut node Node) config_path_get() string {
	return executor.environ_get()['HOME'] + '/.config/manifestor/${node.name}.json'
}


pub fn (mut node Node) load() {	

	fpath := node.config_path_get()
    statedata := node.executor.file_read(fpath) or {
		node.done = map[string]bool
		platform = PlatformType.unknown
        return
    }
    conf2 := json.decode(Node, statedata) or {
        panic('Failed to parse json for $fpath.\n Data was $statedata')
    }
	//why do we have to repeat this
	// node.done = conf2.done
	// node.platform = conf2.platform
}

pub fn (mut node Node) reset() {	
	fpath := node.config_path_get()
	node.executor.remove(fpath)
	node.load()
}

pub fn (mut node Node) save() {	
	fpath := node.config_path_get()
	node.executor.file_write(fpath,json.encode(node))	
}

// pub fn (mut node Node) check(name string) {	
// 	node.
// }

pub fn node_get(name string) Node{
	mut data := Node{name: name,executor:ExecutorLocal{}}
	data.load()
	return data
}


