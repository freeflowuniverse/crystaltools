module main

import installers
import os
import cli

install_exec := fn (cmd cli.Command) ? {
    installers.main()?
}

mut install_cmd := cli.Command{
    name: 'install'
    execute: install_exec
    required_args: 0
}

// sub_cmd.install_cmd(cli.Flag{
//     name: 'test'
//     abbrev: 't'
//     description: 'this is a test argument'
//     // required: true
//     flag: cli.FlagType.string
// })



mut main_cmd := cli.Command{
    name: 'installer'
    commands: [install_cmd]
    description: "

    Publishing Tool Installer
	This tool helps you to install & run wiki & websites

    "    
}


main_cmd.setup()
main_cmd.parse(os.args)

