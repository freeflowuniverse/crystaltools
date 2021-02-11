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


fn (mut config ConfigRoot) site_get(name string) ?SiteConfig {	
	for site in config.sites {
		if site.name.to_lower() == name.to_lower() {
			return site
		}
	}
	return error('Cannot find wiki site with name: $name')
}


//return using alias or name (will first use alias)
pub fn (mut config ConfigRoot) site_web_get(name string) ?SiteConfig {	
	mut name2 := name.to_lower()
	if name2.starts_with("www_"){
		name2 = name2[4..]
	}
	if name2.starts_with("wiki_"){
		return error("cannot ask for wiki")
	}
	for site in config.sites {
		if site.cat == SiteCat.web {
			if site.alias.to_lower() == name2 {
				return site
			}
			if site.name.to_lower() == name2 {
				return site
			}
		}
	}
	return error('Cannot find web site with name: $name')
}


//return using alias or name (will first use alias)
pub fn (mut config ConfigRoot) site_wiki_get(name string) ?SiteConfig {	
	mut name2 := name.to_lower()
	if name2.starts_with("wiki_"){
		name2 = name2[5..]
	}
	if name2.starts_with("www_"){
		return error("cannot ask for www")
	}
	for site in config.sites {
		if site.cat == SiteCat.wiki {
			if site.alias.to_lower() == name2 {
				return site
			}
			if site.name.to_lower() == name2 {
				return site
			}
		}
	}
	return error('Cannot find wiki site with name: $name')
}
