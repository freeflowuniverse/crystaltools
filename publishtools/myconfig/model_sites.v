module myconfig

pub struct SiteConfig {
pub mut:
	name   string
	url    string
	branch string = 'default' // means is the default branch
	pull   bool
	cat    SiteCat
	alias  string
}

pub enum SiteCat {
	wiki
	data
	web
}
