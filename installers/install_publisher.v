module main

import installers
import os
import cli


fn main() {
    install_exec := fn (cmd cli.Command) ? {
        installers.main(cmd)?
    }

    mut install_cmd := cli.Command{
        name: 'install'
        execute: install_exec
        required_args: 0
    }

    install_cmd.add_flag(cli.Flag{
        name: 'pull'
        description: 'do you want to pull the git repo\'s'
        flag: cli.FlagType.bool
    })

    install_cmd.add_flag(cli.Flag{
        name: 'reset'
        description: 'will reset the env before installing'
        flag: cli.FlagType.bool
    })


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

}