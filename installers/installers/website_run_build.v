module installers

import myconfig
import process
import gittools
import cli

fn conf_repo_get(cmd &cli.Command) ?(myconfig.ConfigRoot, &gittools.GitRepo) {
	mut name := cmd.args[0]

	mut conf := myconfig.get()

	mut res := []string{}
	for site in conf.sites {
		if site.name.contains(name) {
			res << site.name
		}
	}

	if res.len == 1 {
		name = res[0]
	} else if res.len > 1 {
		sites_list(cmd) ?
		return error('Found more than 1 or wiki or website with name: $name')
	} else {
		sites_list(cmd) ?
		return error('Cannot find repo or wiki with name: $name')
	}

	mut gt := gittools.new(conf.paths.code) or { return error('ERROR: cannot load gittools:$err') }

	mut repo := gt.repo_get(name: name) or { return error('ERROR: cannot find repo: $name\n$err') }

	return conf, repo
}

pub fn sites_list(cmd &cli.Command) ? {
	mut conf := myconfig.get()

	for site in conf.sites {
		println(' - $site.name')
	}
}

pub fn website_run(cmd &cli.Command) ? {
	_, repo := conf_repo_get(cmd) ?

	println(' - start website: $repo.path')
	process.execute_interactive('$repo.path/run.sh') ?
}

pub fn website_build(cmd &cli.Command) ? {
	_, repo := conf_repo_get(cmd) ?

	println(' - build website: $repo.path')
	process.execute_interactive('$repo.path/build.sh') ?
}
