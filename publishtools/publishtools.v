module main

import installers
import os
import cli
import publisher
import myconfig

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
		mut arg := false
		for flag in cmd.flags {
			if flag.name == 'repo' {
				if flag.value.len > 0 {
					arg = true
				}
			}
		}

		if ! arg {
			// publisher.webserver_start_develop()
			println(' ERROR: need to implement webserver_start_develop')
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
		cfg := myconfig.get()
		mut publ := publisher.new(cfg.paths.code) or { panic('cannot init publisher. $err') }
		publ.check()
		publ.flatten(cfg.paths.publish)
		publisher.webserver_start_build()
	}
	mut run_cmd := cli.Command{
		description: 'run all websites & wikis, they need to be build first'
		name: 'run'
		execute: run_exec
		required_args: 0
	}

	// BUILD
	build_exec := fn (cmd cli.Command) ? {
		cfg := myconfig.get()
		mut publ := publisher.new(cfg.paths.code) or { panic('cannot init publisher. $err') }
		publ.check()
		publ.flatten(cfg.paths.publish)

		installers.website_build(&cmd) ?
	}
	mut build_cmd := cli.Command{
		name: 'build'
		usage: 'specify name of website or wiki to run'
		execute: build_exec
		required_args: 0
	}
	build_cmd.add_flag(repoflag)

	// LIST
	list_exec := fn (cmd cli.Command) ? {
		installers.sites_list(&cmd) ?
	}
	mut list_cmd := cli.Command{
		name: 'list'
		execute: list_exec
	}

	// PULL
	pull_exec := fn (cmd cli.Command) ? {
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


	// pushcommit
	pushcommit_exec := fn (cmd cli.Command) ? {
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
		mut cfg := installers.config_get(cmd) ?
		installers.digitaltwin_start(&cfg) or {
			return error(' ** ERROR: cannot start digital twin. Error was:\n$err')
		}
	}
	mut twin_cmd := cli.Command{
		name: 'digitaltwin'
		execute: twin_exec
	}

	// MAIN
	mut main_cmd := cli.Command{
		name: 'installer'
		commands: [install_cmd, run_cmd, build_cmd, list_cmd, develop_cmd, twin_cmd, pull_cmd,
			commit_cmd, push_cmd, pushcommit_cmd,edit_cmd]
		description: '

        Publishing Tool Installer
        This tool helps you to install & run wiki & websites

        '
	}

	main_cmd.setup()
	main_cmd.parse(os.args)

	// println(' - OK')
}
