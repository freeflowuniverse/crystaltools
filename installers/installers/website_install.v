module installers

import os
import myconfig
import process
import gittools
import texttools

// Initialize (load wikis) only once when server starts
pub fn website_install(name string, first bool, conf &myconfig.ConfigRoot) ? {
	base := conf.paths.base
	codepath := conf.paths.code
	nodejspath := conf.paths.nodejs

	mut gt := gittools.new(codepath) or { return error('ERROR: cannot load gittools:$err') }

	mut repo := gt.repo_get(name: name) or { return error('ERROR: cannot load gittools:$err') }
	println(' - install website (can take long) on $repo.path')

	if conf.reset {
		script6 := '
		
		cd $repo.path

		rm -rf modules
		rm -f .installed

		'
		process.execute_silent(script6) or {
			return error('cannot install node modules for ${name}.\n$err')
		}
	}

	if os.exists('$repo.path/.installed') {
		return
	}

	script_install := '

	set -ex
	
	cd $repo.path

	rm -f yarn.lock
	rm -rf .cache		
	
	source $base/nvm.sh
	
	nvm use --lts
	npm install

	if [ "$first" = true ]; then
		rsync -ra --delete node_modules/ $base/node_modules/
	else
		rsync -ra --delete $base/node_modules/ node_modules/ 
	fi

	'

	script_run := '

	source $base/nvm.sh

	cd $repo.path

	nvm use --lts

	export PATH=$nodejspath/bin:\$PATH

	gridsome develop

	'

	os.write_file('$repo.path/install.sh', texttools.dedent(script_install)) or {
		return error('cannot write to $repo.path/install.sh\n$err')
	}
	os.write_file('$repo.path/run.sh', texttools.dedent(script_run)) or {
		return error('cannot write to $repo.path/run.sh\n$err')
	}

	process.execute_silent(script_install) or {
		return error('cannot install node modules for ${name}.\n$err')
	}

	// println(job)

	// process.execute_silent("mkdir -p $repo.path/content") ?

	for x in ['blog', 'person', 'news', 'project'] {
		if os.exists('$repo.path/content') {
			process.execute_silent('rm -rf $repo.path/content/$x\n') ?
			os.symlink('$codepath/github/threefoldfoundation/data_threefold/content/$x',
				'$repo.path/content/$x') or {
				return error('Cannot link $x from data path to repo path.\n$err')
			}
		}
	}

	os.write_file('$repo.path/.installed', '') or {
		return error('cannot write to $repo.path/.installed\n$err')
	}
}
