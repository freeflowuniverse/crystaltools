module installers

import cli
import gittools
import myconfig
import publisher
import readline
import os

pub fn sites_list(cmd &cli.Command) ? {
	mut conf := myconfig.get()
	mut gt := gittools.new(conf.paths.code) or { return error('cannot load gittools:$err') }
	for site in conf.sites {
		mut repo := gt.repo_get(name: site.name) or { return error('ERROR: cannot get repo:$err') }
		change := repo.changes() or {
			return error('cannot detect if there are changes on repo.\n$err')
		}
		if change {
			println(' - $site.name (CHANGES)')
		} else {
			println(' - $site.name')
		}
	}
}

pub fn sites_get(cmd cli.Command) ? {
	mut cfg := config_get(cmd) ?
	mut gt := gittools.new(cfg.paths.code) or { return error('cannot load gittools:$err') }
	println(' - get all code repositories.')

	for sc in cfg.sites {
		println(' - get:$sc.url')
		gt.repo_get_from_url(url: sc.url, pull: sc.pull) ?
	}
}

pub fn sites_install(cmd cli.Command) ? {
	mut cfg := config_get(cmd) ?
	println(' - sites install.')
	mut first := true
	for sc in cfg.sites {
		if sc.cat == myconfig.SiteCat.web {
			website_install(sc.name, first, &cfg) ?
			first = false
		}
	}
}

fn flag_message_get(cmd cli.Command) string {
	for flag in cmd.flags {
		if flag.name == 'message' {
			if flag.value.len == 0 {
				msg := readline.read_line('Message for commit?:') or { panic(err) }
				return msg
			}
			return flag.value[0]
		}
	}
	msg := readline.read_line('Message for commit?:') or { panic(err) }
	return msg
}

fn flag_repo_do(cmd cli.Command, reponame string) bool {
	for flag in cmd.flags {
		if flag.name == 'repo' {
			if flag.value.len > 0 {
				// ch1 := reponame.to_lower()
				// ch2 :=  flag.value[0].to_lower()
				// println('check repo do: $ch1  == $ch2')
				if reponame.to_lower().contains(flag.value[0].to_lower()) {
					// println("FOUND")
					return true
				} else {
					return false
				}
			}
		}
	}
	return false
}

pub fn sites_pull(cmd cli.Command) ? {
	mut cfg := config_get(cmd) ?
	println(' - sites pull.')
	codepath := cfg.paths.code
	mut gt := gittools.new(codepath) or { return error('ERROR: cannot load gittools:$err') }
	for sc in cfg.sites {
		mut repo := gt.repo_get(name: sc.name) or { return error('ERROR: cannot get repo:$err') }
		if ! flag_repo_do(cmd, repo.addr.name) {
			continue
		}
		println(' - pull  $repo.path')
		repo.pull(force: cfg.reset) or { return error('ERROR: cannot pull repo $repo.path :$err') }
	}
}

pub fn sites_push(cmd cli.Command) ? {
	mut cfg := config_get(cmd) ?
	println(' - sites push.')
	codepath := cfg.paths.code
	mut gt := gittools.new(codepath) or { return error('ERROR: cannot load gittools:$err') }
	for sc in cfg.sites {
		mut repo := gt.repo_get(name: sc.name) or { return error('ERROR: cannot get repo:$err') }
		if ! flag_repo_do(cmd, repo.addr.name) {
			continue
		}		
		println(' - push  $repo.path')
		change := repo.changes() or {
			return error('cannot detect if there are changes on repo.\n$err')
		}
		if change {
			repo.push() or { return error('ERROR: cannot push repo $repo.path :$err') }
			println('     > ok')
		} else {
			println('     > nochange')
		}
	}
}

pub fn sites_commit(cmd cli.Command) ? {
	mut cfg := config_get(cmd) ?
	println(' - sites commit.')
	msg := flag_message_get(cmd)
	codepath := cfg.paths.code
	mut gt := gittools.new(codepath) or { return error('ERROR: cannot load gittools:$err') }
	for sc in cfg.sites {
		mut repo := gt.repo_get(name: sc.name) or { return error('ERROR: cannot get repo:$err') }
		if ! flag_repo_do(cmd, repo.addr.name) {
			continue
		}		
		change := repo.changes() or {
			return error('cannot detect if there are changes on repo.\n$err')
		}
		println(' - $repo.path')
		if change {
			println('     > commit message: $msg')
			repo.commit(msg) or { return error('ERROR: cannot commit repo $repo.path :$err') }
		} else {
			println('     > no change')
		}
	}
}

pub fn sites_pushcommit(cmd cli.Command) ? {
	mut cfg := config_get(cmd) ?
	println(' - sites commit, pull, push')
	codepath := cfg.paths.code
	mut gt := gittools.new(codepath) or { return error('ERROR: cannot load gittools:$err') }
	msg := flag_message_get(cmd)
	for sc in cfg.sites {
		mut repo := gt.repo_get(name: sc.name) or { return error('ERROR: cannot get repo:$err') }
		if ! flag_repo_do(cmd, repo.addr.name) {
			continue
		}		
		println(' - $repo.path')
		change := repo.changes() or {
			return error('cannot detect if there are changes on repo.\n$err')
		}
		if change {
			println('     > commit')
			repo.commit(msg) or { return error('ERROR: cannot commit repo $repo.path :$err') }
		}
		println('     > pull')
		repo.pull(force: cfg.reset) or { return error('ERROR: cannot pull repo $repo.path :$err') }
		if change {
			println('     > push')
			repo.push() or { return error('ERROR: cannot push repo $repo.path :$err') }
		}
	}
}

pub fn sites_cleanup(cmd cli.Command) ? {
	mut cfg := config_get(cmd) ?
	println(' - cleanup wiki.')
	mut publisher := publisher.new(cfg.paths.code) or { panic('cannot init publisher. $err') }
	publisher.check()
	println(' - cleanup websites.')
	for sc in cfg.sites {
		if sc.cat == myconfig.SiteCat.web {
			website_cleanup(sc.name, &cfg) ?
		} else if sc.cat == myconfig.SiteCat.wiki {
			wiki_cleanup(sc.name, &cfg) ?
		}
	}
}


pub fn site_edit(cmd cli.Command) ? {
	mut cfg := config_get(cmd) ?
	codepath := cfg.paths.code
	mut gt := gittools.new(codepath) or { return error('ERROR: cannot load gittools:$err') }
	for sc in cfg.sites {
		mut repo := gt.repo_get(name: sc.name) or { return error('ERROR: cannot get repo:$err') }
		if ! flag_repo_do(cmd, repo.addr.name) {
			continue
		}		
		// println(' - $repo.path')
		os.execvp("code", [repo.path])?
	}
}
