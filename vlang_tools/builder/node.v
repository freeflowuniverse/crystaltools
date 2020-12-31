module builder

pub enum PlatformType {
	unknown
	osx
	ubuntu
	alpine
}

pub struct Node {
	name     string = 'mymachine'
pub mut:
	executor Executor // = ExecutorLocal{}
	platform PlatformType
}

pub struct NodeArguments {
	ipaddr   IPAddress
	name     string
	platform PlatformType
}

// the factory which returns an node, based on the arguments will chose ssh executor or the local one
pub fn node_get(args NodeArguments) Node {
	mut node := Node{}
	if args.ipaddr.addr == '' || args.ipaddr.addr == 'localhost' || args.ipaddr.addr == '127.0.0.1' {
		node.executor = ExecutorLocal{}
	} else {
		node.executor = ExecutorSSH{}
	}
	return node
	// match executor {
	//     ExecutorSSH {node.executor.platform_load()}
	//     ExecutorLocal {node.executor.platform_load()}
	// }
}
