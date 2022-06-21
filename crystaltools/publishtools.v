module main

import os
import freeflowuniverse.crystallib.publisher_core
import cli


fn main() {

	messageflag := cli.Flag{
		name: 'path'
		abbrev: 'p'
		description: 'path of the config markdown file'
		flag: cli.FlagType.string
	}	
	run_exec := fn (cmd cli.Command) ? {
		flags := cmd.flags.get_all_found()
		path := flags.get_string('path') or {
			println("do publishtools -p path_of_the_markdown")
			exit(1)
		}
		mut publ := publisher_core.run(actions_path:path) ?
	}
	mut app := cli.Command{
		name: 'run'
		execute: run_exec
	}
	app.add_flag(messageflag)

    app.setup()
    app.parse(os.args)


}

