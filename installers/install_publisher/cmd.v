module installerpublisher

module main
import nodejs
import process
import cli
import os
import gittools
import builder
import texttools
import config

pub fn new() cli.Command {
	mut app := cli.Command{
		name: 'publishing tools'
		description: 'publishing tools'
		execute: root
	app.setup()
	app.parse(os.args)
}


fn (cmd cli.Command) root() ? {
			ourreset := true
			if ourreset {
				reset() or {
					println(' ** ERROR: cannot reset. Error was:\n$err')
					exit(1)
				}
			}
			step1() or {
				println(' ** ERROR: cannot prepare system. Error was:\n$err')
				exit(1)
			}
			getsites() or {
				println(' ** ERROR: cannot get web & wiki sites. Error was:\n$err')
				exit(1)
			}
			npm() or {
				println(' ** ERROR: cannot install npm. Error was:\n$err')
				exit(1)
			}		}
		commands: [
			cli.Command{
				name: 'export'
				execute: export
			},
		]
	}


fn (cmd cli.Command) export() ? {
	println('export')
}	

fn step1() ? {
	base := base_path_get()

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

fn getsites() ? {
	base := code_path_get()

	if !os.exists('$base/codesync') {
		os.mkdir('$base/codesync') or { return error(err) }
	}
	// get publisher, check for all wiki's
	mut gt := gittools.new('$base') or { return error('cannot load gittools:$err') }

	println(' - get all code repositories.')
}

fn reset() ? {
	base := base_path_get()
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

fn npm() ? {
	base := base_path_get()

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

	nodejspath := nodejs_path_get()
	if !os.exists('$nodejspath/bin/node') {
		println(' - will install nodejs (can take quite a while)')
		script := '
		set -e
		export NVM_DIR=$base
		source $base/nvm.sh
		nvm install --lts
		npm install -g grunt
		npm install -g gridsome
		npm install -g @gridsome/cli
		'
		process.execute_silent(script) or {
			println('cannot install nodejs.\n$err')
			exit(1)
		}
	}

	println(' - nodejs installed')
}

// Initialize (load wikis) only once when server starts
fn website_install(name string, first bool, reset bool) ? {
	base := base_path_get()
	codepath := code_path_get()
	nodejspath := nodejs_path_get()

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
