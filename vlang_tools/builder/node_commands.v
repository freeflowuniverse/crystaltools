module builder

// check command exists on the platform, knows how to deal with different platforms
pub fn (mut node Node) cmd_exists(cmd string) bool {
	node.executor.exec_silent('which $cmd') or { return false }
	return true
}

pub fn (mut node Node) exec_ok(cmd string) bool {
	node.executor.exec_silent(cmd) or {
		// see if it executes ok, if cmd not found is false
		return false
	}
	// println(e)
	return true
}

fn (mut node Node) platform_load() {
	if node.platform == PlatformType.unknown {
		if node.cmd_exists('sw_vers') {
			node.platform = PlatformType.osx
		} else if node.cmd_exists('apt') {
			node.platform = PlatformType.ubuntu
		} else if node.cmd_exists('apk') {
			node.platform = PlatformType.alpine
		} else {
			panic('only ubuntu, alpine and osx supported for now')
		}
	}
}

pub fn (mut node Node) platform_prepare() ? {
	node.platform_load()
	if node.platform == PlatformType.osx {
		if ! node.cmd_exists("brew"){
			node.executor.exec('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"') or {
				return error("cannot install brew, something went wrong.\n$err")
			}
		}
		if ! node.cmd_exists("clang"){
			node.executor.exec('xcode-select --install') or {
				return error("cannot install xcode-select --install, something went wrong.\n$err")
			}
		}		
	} else if node.platform == PlatformType.ubuntu {
		println("ubuntu prepare")
	} else {
		panic('only ubuntu and osx supported for now')
	}	
	for x in ["mc","git","rsync","curl"]{
		if ! node.cmd_exists(x){
			node.package_install({name:"x"})?	
		}
	}	
}

pub fn (mut node Node) package_install(package Package) ? {
	name := package.name
	node.platform_load()
	if node.platform == PlatformType.osx {
		node.executor.exec('brew install $name') or {return error("could not install package:${package.name}\nerror:\n$err")}
	} else if node.platform == PlatformType.ubuntu {
		node.executor.exec('apt install $name -y') or {return error("could not install package:${package.name}\nerror:\n$err")}
	} else if node.platform == PlatformType.alpine {
		node.executor.exec('apk install $name') or {return error("could not install package:${package.name}\nerror:\n$err")}
	} else {
		panic('only ubuntu, alpine and osx supported for now')
	}
}

pub fn (mut node Node) get_free_port() ?int{
	port := node.executor.exec("bash -c \"comm -23 <(seq 49152 65535 | sort) <(ss -Htan | awk '{print $$4}' | cut -d':' -f2 | sort -u) | shuf | head -n 1\"") or {panic(err)}
	return port.int()
}
