module nodejs
import config
import os
import builder

fn nodejs_path_get() string {
	config := nodejs_config()
	return config.path
}

fn (mut npm NpmConfig) init(){
	if npm.path == ""{
		base := config.base_path_get()	
		if config.version.cat == NpmVersionEnum.lts{
			version := "v15.8.0"
		}else{
			version := "v14.15.4"
		}
		npm.path = "${base}/versions/node/$version"
		npm.version.version = version
	}	
}

//return string which represents init for npm
pub fn (mut npm NpmConfig) init_string() string {
	return ""
}

pub fn (mut npm NpmConfig) install() ? {

	npm.init()

	base := config.base_path_get()

	mut node := builder.node_get({}) or {
		println(' ** ERROR: cannot load node. Error was:\n$err')
		exit(1)
	}
	node.platform_prepare() ?

	if !os.exists('$base/nvm.sh') {
		script := "
		set -e
		rm -f $base/nvm.sh
		curl -s -o '$base/nvm.sh' https://raw.githubusercontent.com/nvm-sh/nvm/master/nvm.sh
		"
		process.execute_silent(script) or {
			println('cannot download nvm script.\n$err')
			exit(1)
		}
	}

	nodejspath := config.nodejs_path_get()
	if !os.exists('$nodejspath/bin/node') {
		println(' - will install nodejs (can take quite a while)')
		if npm.version.cat == NpmVersionEnum.lts {
			script := '
			set -e
			export NVM_DIR=$base
			source $base/nvm.sh
			nvm install --lts
			'
		}else{
			script := '
			set -e
			export NVM_DIR=$base
			source $base/nvm.sh
			nvm install node
			'			
		}
		process.execute_silent(script) or {
			println('cannot install nodejs.\n$err')
			exit(1)
		}
	}

	println(' - nodejs installed')
}