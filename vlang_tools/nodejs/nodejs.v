module nodejs
import myconfig
import os
import builder
import process

fn (mut nodeconfig NodejsConfig) init(){
	mut version:= ""
	if nodeconfig.path == ""{
		base := config.base_path_get()	
		if nodeconfig.version.cat == nodejs.NodejsVersionEnum.lts{
			version = "v15.8.0"
		}else{
			version = "v14.15.4"
		}
		nodeconfig.path = "${base}/versions/node/$version"
		nodeconfig.version.name = version
	}	
}

//return string which represents init for npm
pub fn (mut npm NodejsConfig) init_string() string {
	return ""
}

pub fn (mut npm NodejsConfig) install() ? {

	mut script := ""

	npm.init()

	base := myconfig.base_path_get()

	mut node := builder.node_get({}) or {
		println(' ** ERROR: cannot load node. Error was:\n$err')
		exit(1)
	}
	node.platform_prepare() ?

	if !os.exists('$base/nvm.sh') {
		script = "
		set -e
		rm -f $base/nvm.sh
		curl -s -o '$base/nvm.sh' https://raw.githubusercontent.com/nvm-sh/nvm/master/nvm.sh
		"
		process.execute_silent(script) or {
			println('cannot download nvm script.\n$err')
			exit(1)
		}
	}

	nodejspath := myconfig.nodejs_path_get()
	if !os.exists('$nodejspath/bin/node') {
		println(' - will install nodejs (can take quite a while)')
		if npm.version.cat == NodejsVersionEnum.lts {
			script = '
			set -e
			export NVM_DIR=$base
			source $base/nvm.sh
			nvm install --lts
			'
		}else{
			script = '
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