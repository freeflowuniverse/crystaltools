module manifestor

// is e.g. an ubuntu packaged app, it needs to be packaged by the package maintainers !

pub struct Command {
    cmd        	 	string
	arguments		[]string
	//timeout in seconds, default 5 min
	timeout			int = 300
	retry			int = 1
	stdout_log		true
	stderr_log		true
	pub mut:
		time_start int
		time_stop int
		stdout str
		sterr str
		state CmdState
}

//if there is an exception of how package needs to be installed (alias)
// e.g. on ubuntu something is called myapp but on alpine its my_app
pub struct PackageAlias {
    name        	 string
	platformtype     PlatformType
}

//get the right name depending the platform type
pub fn (mut package PackageAlias) name_get(platformtype PlatformType) {

	for alias in package.aliases {
		if alias.platformtype == platformtype {
			return alias.name
		}
	}
	return package.name
}

