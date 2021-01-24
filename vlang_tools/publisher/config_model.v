module publisher

pub struct Config {
pub mut:
	sites 		 []ConfigSite
}

pub struct ConfigSite {
pub mut:
	name 		 string
	url 		 string
	
}

pub fn config_get() ?Config {
	return Config{}
}

