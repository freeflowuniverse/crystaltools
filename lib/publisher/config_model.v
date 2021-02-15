module publishermod

pub struct Config {
pub mut:
	sites []ConfigSite
}

pub struct ConfigSite {
pub mut:
	name    string
	url     string
// 	alias   []string
// 	replace []string
}

pub fn config_get() ?Config {
	return Config{}
}

// NOT USED YET
// NOT USED YET
// NOT USED YET
// NOT USED YET
// NOT USED YET
