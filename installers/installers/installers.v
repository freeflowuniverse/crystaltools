module installers

import cli
import os
import gittools
import builder
import myconfig
import process
import nodejs

pub fn main(cmd cli.Command) ? {
	cfg := myconfig.get()

	mut ourreset := false
	for flag in cmd.flags {
		if flag.name == 'reset' && flag.value.len > 0 {
			ourreset = true
		}
	}

	if ourreset {
		println(' - reset the full system')
		reset() or { return error(' ** ERROR: cannot reset. Error was:\n$err') }
	}
	base() or { return error(' ** ERROR: cannot prepare system. Error was:\n$err') }

	nodejs.install(&cfg) or { return error(' ** ERROR: cannot install nodejs. Error was:\n$err') }

	getsites(cmd) or { return error(' ** ERROR: cannot get web & wiki sites. Error was:\n$err') }
}

pub fn base() ? {
	base := myconfig.get().paths.base

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

pub fn getsites(cmd cli.Command) ? {
	mut cfg := myconfig.get()

	for flag in cmd.flags {
		if flag.name == 'pull' && flag.value.len > 0 {
			cfg.pull = true
		}
		if flag.name == 'reset' && flag.value.len > 0 {
			cfg.reset = true
		}
	}

	if !os.exists(cfg.paths.code) {
		os.mkdir(cfg.paths.code) or { return error(err) }
	}
	// get publisher, check for all wiki's
	mut gt := gittools.new(cfg.paths.code) or { return error('cannot load gittools:$err') }

	println(' - get all code repositories.')
	mut first := true
	for sc in cfg.sites {
		//, branch: sc.branch
		gt.repo_get_from_url(url: sc.url, pull: sc.pull) ?

		if sc.cat == myconfig.SiteCat.web {
			// website_cleanup(sc.name, &cfg) ?
			// website_install(sc.name,first,&cfg) ?
			first = false
		} else if sc.cat == myconfig.SiteCat.wiki {
			wiki_cleanup(sc.name, &cfg) ?
		}
	}
}

pub fn reset() ? {
	base := myconfig.get().paths.base
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
