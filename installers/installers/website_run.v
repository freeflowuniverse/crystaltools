module installers

import myconfig
import process
import gittools

pub fn website_run(name string, conf &myconfig.ConfigRoot) ? {
	codepath := conf.paths.code

	mut gt := gittools.new(codepath) or { return error('ERROR: cannot load gittools:$err') }

	mut repo := gt.repo_get(name: name) or { return error('ERROR: cannot load gittools:$err') }
	println(' - start website: $repo.path')

	process.execute_interactive('$repo.path/run.sh') ?
}
