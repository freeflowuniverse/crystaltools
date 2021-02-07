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
		if cmd.args.len == 0 {
			publisher.webserver_start_develop()
			println(" ERROR: need to implement webserver_start_develop")
		}else{
			installers.website_develop(&cmd) ?
		}
	}
	mut develop_cmd := cli.Command{
		name: 'develop'
		usage: 'specify name of website to develop on'
		execute: develop_exec
		required_args: 0
	}

	// RUN
	run_exec := fn (cmd cli.Command) ? {
		cfg := myconfig.get()
		mut publ := publisher.new(cfg.paths.code) or { panic('cannot init publisher. $err') }
		publ.check()
		publ.flatten(cfg.paths.publish)
		//TODO: now we need to run a webserver which exposes all flattened directories
		// publisher.webserver_start_build()
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

	// LIST
	list_exec := fn (cmd cli.Command) ? {
		installers.sites_list(&cmd) ?
	}
	mut list_cmd := cli.Command{
		name: 'list'
		execute: list_exec
	}

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
		commands: [install_cmd, run_cmd, build_cmd, list_cmd, develop_cmd, twin_cmd]
		description: '

        Publishing Tool Installer
        This tool helps you to install & run wiki & websites

        '
	}

	main_cmd.setup()
	main_cmd.parse(os.args)

	println(' - OK')
}
