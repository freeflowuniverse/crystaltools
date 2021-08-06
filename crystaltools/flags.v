module main

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

no_path_prefix_flag := cli.Flag{
	name: 'nopathprefix'
	abbrev: 'p'
	description: 'Build website(s) without alias/path prefix'
	flag: cli.FlagType.bool
}
