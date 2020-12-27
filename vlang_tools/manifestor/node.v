module manifestor

type Executor = ExecutorLocal | ExecutorSSH
pub enum PlatformType { unknown osx ubuntu alpine }

pub struct Node {
	name string = "mymachine"	
	executor Executor	
	mut:
		platformtype PlatformType
}

struct NodeArguments{
	ipaddr IPAddress
}

//the factory which returns an node, based on the arguments will chose ssh executor or the local one
fn node_get (args NodeArguments) Node {
	if args.ipaddr.addr == "" {
		return Node{executor:ExecutorLocal{}}
	}else{
		return Node{executor:ExecutorSSH{ipaddr:args.ipaddr}}
	}
	match executor {
        ExecutorSSH {node.executor.platform_load()}
        ExecutorLocal {node.executor.platform_load()}
    }
}
