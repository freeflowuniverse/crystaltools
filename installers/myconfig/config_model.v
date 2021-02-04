module myconfig


pub struct ConfigRoot {
pub mut:
	root string
}

pub struct SiteConfigs {
pub mut:
	sites []SiteConfig
}

pub struct SiteConfig {
pub mut:
	name   string
	url    string
	branch string = 'default' // means is the default branch
	pull   bool
	cat    SiteCat
}

pub enum SiteCat {
	info
	data
	web
	html
}

pub struct NodejsConfig {
pub mut:
	version NodejsVersion
	path    string
}

pub struct NodejsVersion {
pub mut:
	version string
	cat     NodejsVersionEnum
}

pub enum NodejsVersionEnum {
	lts
	latest
}



