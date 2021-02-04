module myconfig

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
