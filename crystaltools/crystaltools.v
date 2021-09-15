module main

// import despiegk.crystallib.installers
import os
import readline
// import despiegk.crystallib.process
import despiegk.crystallib.gittools
import cli
// import ct
// import despiegk.crystallib.publisher_core
// import despiegk.crystallib.publisher_config
// import json

const version = '1.0.21'

fn flag_message_get(cmd cli.Command) string {
	flags := cmd.flags.get_all_found()
	msg := flags.get_string('message') or {
		msg := readline.read_line('Message for commit?:') or { panic(err) }
		return msg
	}
	return msg
}

fn flag_names_get(cmd cli.Command) []string {
	flags := cmd.flags.get_all_found()
    repo := flags.get_string('repo') or { return []string{} }
	return [repo]
}

fn main() {


	// resetflag := cli.Flag{
	// 	name: 'reset'
	// 	abbrev: 'r'
	// 	description: 'will reset the env before installing or pulling'
	// 	flag: cli.FlagType.bool
	// }

	messageflag := cli.Flag{
		name: 'message'
		abbrev: 'm'
		description: 'commit message'
		flag: cli.FlagType.string
	}

	filterflag := cli.Flag{
		name: 'filter'
		abbrev: 'f'
		description: 'filter, part of path of code repo'
		flag: cli.FlagType.string
	}

	pullflag := cli.Flag{
		name: 'pull'
		abbrev: 'p'
		description: 'pull git when doing commit or push'
		flag: cli.FlagType.bool
	}




	// repoflag := cli.Flag{
	// 	name: 'repo'
	// 	abbrev: 'r'
	// 	description: 'repository name, can be part of name'
	// 	flag: cli.FlagType.string
	// }

	// VERSION
	version_exec := fn (cmd cli.Command) ? {
		// println(main.version)
		println('s')
	}
	mut version_cmd := cli.Command{
		name: 'version'
		execute: version_exec
	}

	// LIST
	list_exec := fn (cmd cli.Command) ? {
		mut gs := gittools.new()
		filter := cmd.flags.get_string('filter') or {""}
		gs.list(filter:filter)?
	}
	mut list_cmd := cli.Command{
		name: 'list'
		execute: list_exec
	}
	list_cmd.add_flag(filterflag)

	// commit
	commit_exec := fn (cmd cli.Command) ? {
		message := flag_message_get(cmd)
		mut gs := gittools.new()
		filter := cmd.flags.get_string('filter') or {""}
		pull := cmd.flags.get_bool('pull') or {false}
		gs.commit(filter:filter,message:message,pull:pull)?	

	}
	mut commit_cmd := cli.Command{
		name: 'commit'
		execute: commit_exec
	}
	commit_cmd.add_flag(messageflag)
	commit_cmd.add_flag(filterflag)
	commit_cmd.add_flag(pullflag)

	// pushcommit
	pushcommit_exec := fn (cmd cli.Command) ? {
		message := flag_message_get(cmd)
		mut gs := gittools.new()
		filter := cmd.flags.get_string('filter') or {""}
		pull := cmd.flags.get_bool('pull') or {false}
		gs.pushcommit(filter:filter,message:message,pull:pull)?	

	}
	mut pushcommit_cmd := cli.Command{
		name: 'pushcommit'
		execute: pushcommit_exec
	}
	pushcommit_cmd.add_flag(messageflag)
	pushcommit_cmd.add_flag(filterflag)
	pushcommit_cmd.add_flag(pullflag)

	// push
	push_exec := fn (cmd cli.Command) ? {
		mut gs := gittools.new()
		filter := cmd.flags.get_string('filter') or {""}
		gs.push(filter:filter)?	

	}
	mut push_cmd := cli.Command{
		name: 'push'
		execute: push_exec
	}
	push_cmd.add_flag(filterflag)



	// list_cmd.add_flag(resetflag)

	// // PULL
	// pull_exec := fn (cmd cli.Command) ? {
	// 	installers.sites_download(cmd, false) ?
	// 	installers.sites_pull(&cmd) ?
	// }
	// mut pull_cmd := cli.Command{
	// 	name: 'pull'
	// 	execute: pull_exec
	// }
	// pull_cmd.add_flag(resetflag)
	// pull_cmd.add_flag(repoflag)

	// // pushcommit
	// pushcommit_exec := fn (cmd cli.Command) ? {
	// 	installers.sites_download(&cmd, false) ?
	// 	installers.sites_pushcommit(&cmd) ?
	// }
	// mut pushcommit_cmd := cli.Command{
	// 	name: 'pushcommit'
	// 	execute: pushcommit_exec
	// }
	// pushcommit_cmd.add_flag(messageflag)
	// pushcommit_cmd.add_flag(repoflag)

	// // commit
	// commit_exec := fn (cmd cli.Command) ? {
	// 	installers.sites_download(&cmd, false) ?
	// 	installers.sites_commit(&cmd) ?
	// }
	// mut commit_cmd := cli.Command{
	// 	name: 'commit'
	// 	execute: commit_exec
	// }
	// commit_cmd.add_flag(messageflag)
	// commit_cmd.add_flag(repoflag)

	// // PUSH
	// push_exec := fn (cmd cli.Command) ? {
	// 	installers.sites_download(&cmd, false) ?
	// 	installers.sites_push(&cmd) ?
	// }
	// mut push_cmd := cli.Command{
	// 	name: 'push'
	// 	execute: push_exec
	// }
	// push_cmd.add_flag(resetflag)
	// push_cmd.add_flag(repoflag)

	// // UPDATE
	// update_exec := fn (cmd cli.Command) ? {
	// 	installers.publishtools_update() ?
	// 	installers.sites_download(&cmd, false) ?
	// }
	// mut update_cmd := cli.Command{
	// 	name: 'update'
	// 	usage: 'update the tool'
	// 	execute: update_exec
	// 	required_args: 0
	// }

	// // REMOVE CHANGES
	// removechanges_exec := fn (cmd cli.Command) ? {
	// 	installers.sites_download(cmd, false) ?
	// 	installers.sites_removechanges(&cmd) ?
	// }
	// mut removechangese_cmd := cli.Command{
	// 	name: 'removechanges'
	// 	usage: 'remove changes made'
	// 	execute: removechanges_exec
	// 	required_args: 0
	// }

	mut main_cmd := cli.Command{
		name: 'crystaltools'
		commands: [version_cmd, list_cmd, commit_cmd, pushcommit_cmd,push_cmd]
		description: '

		Crystal Tools

        '
	}

	main_cmd.setup()
	main_cmd.parse(os.args)
}
