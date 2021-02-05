module installers

import os
import myconfig
import process
import gittools
import texttools
import publisher

pub fn wiki_cleanup(name string, conf &myconfig.ConfigRoot) ? {
	codepath := conf.paths.code

	mut gt := gittools.new(codepath) or { return error('ERROR: cannot load gittools:$err') }

	mut repo := gt.repo_get(name: name) or { return error('ERROR: cannot load gittools:$err') }
	println(' - cleanup wiki $repo.path')

	gitignore := '
	*.log
	.cache
	.DS_Store
	src/.temp
	content/blog
	content/news
	content/person
	content/project
	node_modules
	!.env.example
	.env
	.env.*
	yarn.lock
	dist
	.installed
	#install.sh
	#run.sh
	'
	os.write_file('$repo.path/.gitignore', texttools.dedent(gitignore)) or {
		return error('cannot write to $repo.path/.gitignore\n$err')
	}

	script_cleanup := '

	set -ex
	
	cd $repo.path

	rm -f yarn.lock
	rm -rf .cache		
	rm -rf modules
	rm -f .installed
	
	git pull
	rm -f install.sh
	rm -f run.sh
	set +e
	git add . -A
	git commit -m "installer cleanup"
	set -e
	git push
	'

	process.execute_stdout(script_cleanup) or { return error('cannot cleanup for ${name}.\n$err') }

	mut publisher := publisher.new(conf.root) or { panic('cannot init publisher. $err') }
	for mut site in publisher.sites {
		site.files_process(mut &publisher) or { panic(err) }
		site.load(mut &publisher) // will check the errors
	}
}
