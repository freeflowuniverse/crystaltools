module installers

import os
import gittools
import builder
import texttools
import myconfig
import process

pub fn main() ?{

	ourreset := true
	if ourreset {
		reset() or {
			return error(' ** ERROR: cannot reset. Error was:\n$err')
		}
	}
	step1() or {
		return error(' ** ERROR: cannot prepare system. Error was:\n$err')
	}
	getsites() or {
		return error(' ** ERROR: cannot get web & wiki sites. Error was:\n$err')
	}
	mut c := myconfig.nodejs_config()
	c.install() or {
		return error(' ** ERROR: cannot install nodejs. Error was:\n$err')
	}
}



pub fn step1() ? {
	base := myconfig.base_path_get()

	mut node := builder.node_get({}) or {
		println(' ** ERROR: cannot load node. Error was:\n$err')
		exit(1)
	}
	node.platform_prepare() ?

	if !os.exists(base) {
		os.mkdir(base) or { return error(err) }
	}

	println(' - installed base requirements')
}

pub fn getsites() ? {
	base := myconfig.code_path_get()

	if !os.exists('$base/codesync') {
		os.mkdir('$base/codesync') or { return error(err) }
	}
	// get publisher, check for all wiki's
	mut gt := gittools.new('$base') or { return error('cannot load gittools:$err') }

	println(' - get all code repositories.')

	scs := myconfig.site_config()
	for sc in scs.sites {
		if sc.cat == myconfig.SiteCat.web {
		}
	}
}

pub fn reset() ? {
	base := myconfig.base_path_get()
	assert base.len > 10 // just to make sure we don't erase all
	script := '
	set -e
	rm -rf $base
	'
	process.execute_silent(script) or {
		println('** ERROR: cannot reset the system.\n$err')
		exit(1)
	}
	println(' - cleanup')
}



// Initialize (load wikis) only once when server starts
pub fn website_install(name string, first bool, reset bool) ? {
	base := myconfig.base_path_get()
	codepath := myconfig.code_path_get()
	nodejspath := myconfig.nodejs_path_get()

	mut gt := gittools.new(codepath) or {
		println('ERROR: cannot load gittools:$err')
		exit(1)
	}

	mut repo := gt.repo_get(name: name) or {
		println('ERROR: cannot load gittools:$err')
		exit(1)
	}
	println(' - install website (can take long) on $repo.path')

	if reset {
		script6 := '
		
		cd $repo.path

		rm -f yarn.lock
		rm -rf .cache		
		rm -rf modules

		'
		process.execute_silent(script6) or {
			println('cannot install node modules for ${name}.\n$err')
			exit(1)
		}
	}

	if first {
		script2 := '
		
		cd $repo.path

		rm -f yarn.lock
		rm -rf .cache		

		git pull
		
		source $base/nvm.sh
		
		nvm use --lts
		npm install

		rsync -ra --delete node_modules/ $base/node_modules/

		'
		process.execute_silent(script2) or {
			println('cannot install node modules for ${name}.\n$err')
			exit(1)
		}
	} else {
		script3 := '
		
		cd $repo.path

		rm -f yarn.lock
		rm -rf .cache

		git pull ; echo 
		
		source $base/nvm.sh
		
		rsync -ra --delete $base/node_modules/ node_modules/ 

		nvm use --lts		
		npm install		

		'
		process.execute_silent(script3) or {
			return error('cannot install node modules for ${name}.\n$err')
		}
	}

	for x in ['blog', 'person', 'news', 'project'] {
		os.rmdir_all('$repo.path/content/$x') or {
			return error('cannot remove the content link to data\n$err')
		}
		os.symlink(' $codepath/data_threefold/content/$x', '$repo.path/content/$x') or {
			return error('Cannot link $x from data path to repo path.\n$err')
		}
		processs.execute_silent('cd $repo.path && git pull') or {
			return error('Error cannot pull git for: $repo.path\n$err')
		}
	}

	script_run := '

	cd $repo.path

	nvm use --lts

	export PATH=$nodejspath/bin:\$PATH

	gridsome develop

	'

	os.write_file('$repo.path/run.sh', texttools.dedent(script_run)) or {
		println('cannot write to $repo.path/run.sh\n$err')
	}
}
