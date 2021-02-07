module installers

import cli
import gittools
import myconfig
import publisher

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
