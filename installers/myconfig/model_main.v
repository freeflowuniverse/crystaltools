module myconfig

pub struct ConfigRoot {
pub mut:
	root   string
	paths  Paths
	sites  []SiteConfig
	nodejs NodejsConfig
	reset  bool
	pull   bool
	debug  bool
	redis  bool
}

pub struct Paths {
pub mut:
	base    string
	code    string
	publish string
}
