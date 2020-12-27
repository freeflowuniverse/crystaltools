module manifestor


//check command exists on the platform, knows how to deal with different platforms
pub fn (mut node Node) cmd_exists(cmd string) bool {	
	return node.executor.exec_ok("which $cmd 2>&1 > /dev/null")
}


pub fn (mut node Node) exec_ok(cmd string) bool {	
	e := node.executor.exec("$cmd 2> /dev/null") or { 
		//see if it executes ok, if cmd not found is false
        return false
    }
	// println(e)
	if e.exit_code == 0 { return true } else {return false}	
}

fn (mut node Node) platform_load() {
	if node.platform == PlatformType.unknown {
		if executor.cmd_exists_check("sw_vers") {
			node.platform = PlatformType.osx
		} else if executor.cmd_exists_check("apt") {		
			node.platform = PlatformType.ubuntu
		} else if executor.cmd_exists_check("apk") {		
			node.platform = PlatformType.alpine
		} else {
			panic ("only ubuntu, alpine and osx supported for now")
		}
	}
}


pub fn (mut node Node) package_install(mut package PackageToInstall) {
	name := package.name
	executor.platform_load()
	if node.platform == PlatformType.osx {
		executor.exec("brew install $name")
	} else if node.platform == PlatformType.ubuntu {
		executor.exec("apt install $name -y")
	} else if node.platform == PlatformType.alpine {
		executor.exec("apk install $name")
	} else {
		panic ("only ubuntu, alpine and osx supported for now")
	}
}




fn (mut node Node) platform_load() {
	if node.executor.platform == PlatformType.unknown {
		if node.cmd_exists("sw_vers") {
			node.executor.platform = PlatformType.osx
		} else if node.cmd_exists("apt") {		
			node.executor.platform = PlatformType.ubuntu
		} else if node.cmd_exists("apk") {		
			node.executor.platform = PlatformType.alpine
		} else {
			panic ("only ubuntu, alpine and osx supported for now")
		}
	}
}


pub fn (mut node Node) package_install(mut package Package) {
	name := package.name
	node.platform_load()
	if node.executor.platform == PlatformType.osx {
		node.exec("brew install $name")
	} else if node.executor.platform == PlatformType.ubuntu {
		node.exec("apt install $name -y")
	} else if node.executor.platform == PlatformType.alpine {
		node.exec("apk install $name")
	} else {
		panic ("only ubuntu, alpine and osx supported for now")
	}
}

