module main

import despiegk.crystallib.installers
import os
import despiegk.crystallib.process
import cli
import despiegk.crystallib.publishermod
import despiegk.crystallib.myconfig

fn flatten(mut publ publishermod.Publisher) bool {
	publ.flatten() or { return false }
	return true
}

fn main() {
	// INSTALL
	pullflag := cli.Flag{
		name: 'pull'
		abbrev: 'p'
		description: "do you want to pull the git repo's"
		flag: cli.FlagType.bool
	}

	resetflag := cli.Flag{
		name: 'reset'
		abbrev: 'r'
		description: 'will reset the env before installing or pulling'
		flag: cli.FlagType.bool
	}

	cleanflag := cli.Flag{
		name: 'clean'
		abbrev: 'c'
		description: 'will clean the env before'
		flag: cli.FlagType.bool
	}

	messageflag := cli.Flag{
		name: 'message'
		abbrev: 'm'
		description: 'commit message'
		flag: cli.FlagType.string
	}

	repoflag := cli.Flag{
		name: 'repo'
		abbrev: 'r'
		description: 'repository name, can be part of name'
		flag: cli.FlagType.string
	}

	path_prefix_flag := cli.Flag{
		name: 'pathprefix'
		abbrev: 'p'
		description: 'Build website(s) with alias prefix'
		flag: cli.FlagType.bool
	}

	production_flag := cli.Flag{
		name: 'production'
		abbrev: 'd'
		description: 'Run digitaltwin wit pm2 as a service'
		flag: cli.FlagType.bool
	}

	staging_flag := cli.Flag{
		name: 'staging'
		abbrev: 's'
		description: 'publish staging'
		flag: cli.FlagType.bool
	}

	install_exec := fn (cmd cli.Command) ? {
		installers.main(cmd) ?
	}

	mut install_cmd := cli.Command{
		name: 'install'
		execute: install_exec
	}
	install_cmd.add_flag(pullflag)
	install_cmd.add_flag(resetflag)
	install_cmd.add_flag(cleanflag)

	// DEVELOP
	develop_exec := fn (cmd cli.Command) ? {
		webrepo := cmd.flags.get_string("repo") or {""}		
		
		if webrepo == "" {
			installers.sites_download(cmd, false) ?
			mut cfg := myconfig.get(true) ?
			mut publ := publishermod.new(cfg.paths.code) or { panic('cannot init publisher. $err') }
			publ.check()
			publ.develop = true
			cfg.update_javascript_files(false)?
			publishermod.webserver_run(publ, cfg) // would be better to have the develop
		} else {
			installers.website_develop(&cmd) ?
		}
	}
	mut develop_cmd := cli.Command{
		name: 'develop'
		usage: 'specify name of website to develop on, if not specified will show the wiki'
		execute: develop_exec
	}
	develop_cmd.add_flag(repoflag)

	// RUN
	run_exec := fn (cmd cli.Command) ? {
		installers.sites_download(cmd, false) ?
		cfg := myconfig.get(false) ?
		mut publ := publishermod.new(cfg.paths.code) or { panic('cannot init publisher. $err') }
		publ.check()
		publ.flatten() ?
		publishermod.webserver_run(publ, cfg)
	}
	mut run_cmd := cli.Command{
		description: 'run all websites & wikis, they need to be build first'
		name: 'run'
		execute: run_exec
		required_args: 0
	}

	// FLATTEN
	flatten_exec := fn (cmd cli.Command) ? {
		installers.sites_download(cmd, false) ?
		cfg := myconfig.get(false) ?
		mut publ := publishermod.new(cfg.paths.code) or { panic('cannot init publisher. $err') }
		publ.check()
		publ.flatten() ?
	}
	mut flatten_cmd := cli.Command{
		name: 'flatten'
		usage: 'specify name of website or wiki to flatten'
		execute: flatten_exec
		required_args: 0
	}
	flatten_cmd.add_flag(repoflag)

	// BUILD
	build_exec := fn (cmd cli.Command) ? {
		installers.sites_download(cmd, true) ?
		cfg := myconfig.get(true) ?
		mut publ := publishermod.new(cfg.paths.code) or { panic('cannot init publisher. $err') }
		publ.check()
		
		installers.website_build(&cmd) ?
	}
	mut build_cmd := cli.Command{
		name: 'build'
		usage: 'specify name of website or wiki to build'
		execute: build_exec
		required_args: 0
	}
	build_cmd.add_flag(repoflag)
	build_cmd.add_flag(path_prefix_flag)

	// LIST
	list_exec := fn (cmd cli.Command) ? {
		installers.sites_download(&cmd, false) ?
		installers.sites_list(&cmd) ?
	}
	mut list_cmd := cli.Command{
		name: 'list'
		execute: list_exec
	}

	// PULL
	pull_exec := fn (cmd cli.Command) ? {
		installers.sites_download(cmd, false) ?
		installers.sites_pull(&cmd) ?
	}
	mut pull_cmd := cli.Command{
		name: 'pull'
		execute: pull_exec
	}
	pull_cmd.add_flag(resetflag)
	pull_cmd.add_flag(repoflag)

	// EDIT
	edit_exec := fn (cmd cli.Command) ? {
		installers.site_edit(&cmd) ?
	}
	mut edit_cmd := cli.Command{
		name: 'edit'
		execute: edit_exec
	}
	edit_cmd.add_flag(repoflag)

	// VERSION
	version_exec := fn (cmd cli.Command) ? {
		println('1.0.11')
	}
	mut version_cmd := cli.Command{
		name: 'version'
		execute: version_exec
	}

	// pushcommit
	pushcommit_exec := fn (cmd cli.Command) ? {
		installers.sites_download(&cmd, false) ?
		installers.sites_pushcommit(&cmd) ?
	}
	mut pushcommit_cmd := cli.Command{
		name: 'pushcommit'
		execute: pushcommit_exec
	}
	pushcommit_cmd.add_flag(messageflag)
	pushcommit_cmd.add_flag(repoflag)

	// commit
	commit_exec := fn (cmd cli.Command) ? {
		installers.sites_download(&cmd, false) ?
		installers.sites_commit(&cmd) ?
	}
	mut commit_cmd := cli.Command{
		name: 'commit'
		execute: commit_exec
	}
	commit_cmd.add_flag(messageflag)
	commit_cmd.add_flag(repoflag)

	// PUSH
	push_exec := fn (cmd cli.Command) ? {
		installers.sites_download(&cmd, false) ?
		installers.sites_push(&cmd) ?
	}
	mut push_cmd := cli.Command{
		name: 'push'
		execute: push_exec
	}
	push_cmd.add_flag(resetflag)
	push_cmd.add_flag(repoflag)

	// DIGITAL TWIN
	twin_exec := fn (cmd cli.Command) ? {
		production := cmd.flags.get_bool("production") or {false}		
		mut cfg := installers.config_get(cmd) ?
		installers.digitaltwin_start(&cfg, production) or {
			return error(' ** ERROR: cannot start digital twin. Error was:\n$err')
		}
	}
	mut twin_cmd := cli.Command{
		name: 'digitaltwin'
		execute: twin_exec
	}

	twin_cmd.add_flag(production_flag)

	// UPDATE
	update_exec := fn (cmd cli.Command) ? {
		installers.publishtools_update() ?
		installers.sites_download(&cmd, false) ?
	}
	mut update_cmd := cli.Command{
		name: 'update'
		usage: 'update the tool'
		execute: update_exec
		required_args: 0
	}

	// REMOVE CHANGES
	removechanges_exec := fn (cmd cli.Command) ? {
		installers.sites_download(cmd, false) ?
		installers.sites_removechanges(&cmd) ?
	}
	mut removechangese_cmd := cli.Command{
		name: 'removechanges'
		usage: 'remove changes made'
		execute: removechanges_exec
		required_args: 0
	}

	// DNS

	dns_execute := fn (cmd cli.Command) ? {
		mut args := os.args.clone()
		if args.len == 3 {
			if args[2] == 'off' {
				publishermod.dns_off(true)
				return
			} else if args[2] == 'on' {
				publishermod.dns_on(true)
				return
			}
		}
		println('usage: publishtools dns on/off')
	}

	mut dns_cmd := cli.Command{
		usage: '<name>'
		description: 'Manage dns records for publish tools'
		name: 'dns'
		execute: dns_execute
	}

	// publish
	publish_exec := fn (cmd cli.Command) ? {
		mut args := os.args.clone()
		mut cfg := myconfig.get(false) ?

		mut env := "Production"
		mut staging := cmd.flags.get_bool("staging") or {false}

		if staging {
			env = "Staging"
		}

		mut ip := ""

		if !staging{
			ip = "104.131.122.247"
		}else{
			ip = ""
		}

		args.delete(0)
		args.delete(0)

		idx := args.index("--staging")
		if idx != -1{
			args.delete(idx)
		}

		mut sync := ""
		mut prefix := cfg.paths.publish + "/"
		mut skip_sites := false
		mut skip_wikis := false

		if "wikis" in args{
			sync += prefix + "wiki_* "
			args.delete(args.index("wikis"))
			skip_wikis = true
		}

		if "sites" in args{
			sync += prefix + "www_* "
			args.delete(args.index("sites"))
			skip_sites = true
		}

		for arg in args{
			if arg.starts_with("www") && skip_sites{
				continue
			}else if arg.starts_with("wiki") && skip_wikis{
				continue
			}else{
				sync += prefix + arg + ""
			}
		}

		if sync == ""{
			sync = "$prefix*"
		}

		println("Syncing to $env" )
		
		
		for line in sync.split(" "){
			println("\t$line")
		}

		process.execute_stdout('rsync -ra --delete $sync root@$ip:/root/.publisher/containerhost/publisher/publish/')?
		println("restarting server\n")
		process.execute_stdout('ssh root@$ip "docker exec -i web \'restart\'"')?
	}

	cache_execute := fn (cmd cli.Command) ? {
		mut args := os.args.clone()
		if args.len == 3 {
			if args[2] == 'update' {
				mut cfg := myconfig.get(true) ?
				cfg.update_javascript_files(true)?
				return
			} 
		}
		println('usage: publishtools cache update')
	}

	mut cache_cmd := cli.Command{
		usage: '<name>'
		description: 'Update javascript cache'
		name: 'cache'
		execute: cache_execute
	}

	mut publis_cmd := cli.Command{
		name: 'publish',
		description: 'Publish websites/wikis to production/staging',
		usage: '\n\nExamples\npublishtools publish wikis  \t\t  		 publish wikis only
publishtools publish sites  \t\t  		 publish sites only
publishtools publish wikis  www_threefold_farming\t publish wikis and certain website
publishtools publish --staging wikis  \t  		 publish wikis only but for stagin',
		execute: publish_exec
	}

	publis_cmd.add_flag(staging_flag)

	// MAIN
	mut main_cmd := cli.Command{
		name: 'installer'
		commands: [install_cmd, run_cmd, build_cmd, list_cmd, develop_cmd, twin_cmd, pull_cmd,
			commit_cmd, push_cmd, pushcommit_cmd, edit_cmd, update_cmd, version_cmd, removechangese_cmd,
			dns_cmd, flatten_cmd, publis_cmd, cache_cmd]
		description: '

        Publishing Tool Installer
        This tool helps you to install & run wiki & websites

        '
	}

	main_cmd.setup()
	main_cmd.parse(os.args)

	// println(' - OK')
}
