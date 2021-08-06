module main
// import despiegk.crystallib.installers
import os
// import despiegk.crystallib.process
import despiegk.crystallib.gittools
import cli
// import ct
// import despiegk.crystallib.publisher_core
// import despiegk.crystallib.publisher_config
// import json

const version = '1.0.21'


fn main() {

	// VERSION
	version_exec := fn (cmd cli.Command) ? {
		// println(main.version)
		println("s")
	}
	mut version_cmd := cli.Command{
		name: 'version'
		execute: version_exec
	}

	// LIST
	list_exec := fn (cmd cli.Command) ? {
		gs := gittools.new("",false) or {panic("init. $err")}
		println(gs)

	}
	mut list_cmd := cli.Command{
		name: 'list'
		execute: list_exec
	}

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
		commands: [version_cmd,list_cmd]
		description: '

		Crystal Tools

        '
	}

	main_cmd.setup()
	main_cmd.parse(os.args)	

}
