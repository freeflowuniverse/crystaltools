module config

// import gittools

pub struct ConfigRoot {
pub mut:
	root string
}

struct SiteConfigs {
mut:
	sites []SiteConfig
}

struct SiteConfig {
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

pub struct NpmConfig {
pub mut:
	version NpmVersion
	path    string
}

struct NpmVersion {
pub mut:
	version string
	cat     NpmVersionEnum
}

pub enum NpmVersionEnum {
	lts
	latest
}



