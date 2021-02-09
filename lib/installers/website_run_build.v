module installers

import myconfig
import process
import gittools
import cli

fn website_conf_repo_get(cmd &cli.Command) ?(myconfig.ConfigRoot, &gittools.GitRepo) {
	mut name := cmd.args[0]
	mut conf := myconfig.get()

	mut res := []string{}
	for site in conf.sites {
		if site.cat == myconfig.SiteCat.web {
			if site.name.contains(name) {
				res << site.name
			}
		}
	}

	if res.len == 1 {
		name = res[0]
	} else if res.len > 1 {
		sites_list(cmd) ?
		return error('Found more than 1 or website with name: $name')
	} else {
		sites_list(cmd) ?
		return error('Cannot find website with name: $name')
	}

	mut gt := gittools.new(conf.paths.code) or { return error('ERROR: cannot load gittools:$err') }
	mut repo := gt.repo_get(name: name) or { return error('ERROR: cannot find repo: $name\n$err') }

	return conf, repo
}

pub fn website_develop(cmd &cli.Command) ? {
	_, repo := website_conf_repo_get(cmd) ?
	println(' - start website: $repo.path')
	process.execute_interactive('$repo.path/run.sh') ?
}

pub fn website_build(cmd &cli.Command) ? {
	if cmd.args.len == 0 {
		println(' - build all websites')
		mut conf := myconfig.get()
		mut gt := gittools.new(conf.paths.code) or {
			return error('ERROR: cannot load gittools:$err')
		}
		for site in conf.sites {
			if site.cat == myconfig.SiteCat.web {
				mut repo2 := gt.repo_get(name: site.name) or {
					return error('ERROR: cannot find repo: $site.name\n$err')
				}
				println(' - build website: $repo2.path')
				process.execute_stdout('$repo2.path/build.sh') ?
			}
		}
	} else {
		_, repo := website_conf_repo_get(cmd) ?
		println(' - build website: $repo.path')
		// be careful process stops after interactive execute
		process.execute_interactive('$repo.path/build.sh') ?
	}
}
