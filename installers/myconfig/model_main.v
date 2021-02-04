module myconfig

pub struct ConfigRoot {
pub mut:
	root   string
	paths  Paths
	sites  []SiteConfig
	nodejs NodejsConfig
}

pub struct Paths {
pub mut:
	base   string
	code   string
	nodejs string
}
