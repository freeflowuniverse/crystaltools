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
		description: "do you want to pull the git repo's"
		flag: cli.FlagType.bool
	}

	resetflag := cli.Flag{
		name: 'reset'
		description: 'will reset the env before installing'
		flag: cli.FlagType.bool
	}

	cleanflag := cli.Flag{
		name: 'clean'
		description: 'will clean the env before'
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
		installers.website_develop(&cmd) ?
	}
	mut develop_cmd := cli.Command{
		name: 'develop'
		usage: 'specify name of website or wiki to develop on'
		execute: develop_exec
		required_args: 1
	}

	// RUN
	run_exec := fn (cmd cli.Command) ? {
		cfg := myconfig.get()
		mut publisher := publisher.new(cfg.paths.code) or { panic('cannot init publisher. $err') }
		publisher.check()
		publisher.flatten(cfg.paths.publish)
	}
	mut run_cmd := cli.Command{
		description: 'run all websites & wikis, they need to be build first'
		name: 'run'
		execute: run_exec
		required_args: 0
	}

	// BUILD
	build_exec := fn (cmd cli.Command) ? {
		installers.website_build(&cmd) ?
	}
	mut build_cmd := cli.Command{
		name: 'build'
		usage: 'specify name of website or wiki to run'
		execute: build_exec
		required_args: 1
	}

	// LIST
	list_exec := fn (cmd cli.Command) ? {
		installers.sites_list(&cmd) ?
	}
	mut list_cmd := cli.Command{
		name: 'list'
		execute: list_exec
	}

	// MAIN
	mut main_cmd := cli.Command{
		name: 'installer'
		commands: [install_cmd, run_cmd, build_cmd, list_cmd, develop_cmd]
		description: '

        Publishing Tool Installer
        This tool helps you to install & run wiki & websites

        '
	}

	main_cmd.setup()
	main_cmd.parse(os.args)

	println(' - OK')
}
