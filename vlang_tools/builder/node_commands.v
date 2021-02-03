module builder

// check command exists on the platform, knows how to deal with different platforms
pub fn (mut node Node) cmd_exists(cmd string) bool {
	node.executor.exec('which $cmd 2>&1 > /dev/null') or { return false }
	return true
}

pub fn (mut node Node) exec_ok(cmd string) bool {
	node.executor.exec('$cmd 2> /dev/null') or {
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

pub fn (mut node Node) package_install(mut package Package) {
	name := package.name
	node.platform_load()
	if node.platform == PlatformType.osx {
		node.executor.exec('brew install $name') or {panic(err)}
	} else if node.platform == PlatformType.ubuntu {
		node.executor.exec('apt install $name -y') or {panic(err)}
	} else if node.platform == PlatformType.alpine {
		node.executor.exec('apk install $name') or {panic(err)}
	} else {
		panic('only ubuntu, alpine and osx supported for now')
	}
}
