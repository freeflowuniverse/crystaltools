module myconfig

import os

pub struct SiteConfig {
pub mut:
	name      string
	url       string
	branch    string = 'default' // means is the default branch
	pull      bool
	cat       SiteCat
	alias     string
	path_code string
}

pub enum SiteCat {
	wiki
	data
	web
}

pub fn (mut site SiteConfig) reponame() string {
	mut name2 := os.base(site.url)
	if name2.ends_with('.git') {
		name2 = name2[..name2.len - 4]
	}
	return name2
}

fn (config ConfigRoot) site_get(name string) ?SiteConfig {
	for site in config.sites {
		if site.name.to_lower() == name.to_lower() {
			return site
		}
	}
	return error('Cannot find wiki site with name: $name')
}

// return using alias or name (will first use alias)
pub fn (mut config ConfigRoot) site_web_get(name string) ?SiteConfig {
	mut name2 := name.to_lower()
	if name2.starts_with('www_') {
		name2 = name2[4..]
	}
	if name2.starts_with('wiki_') {
		return error('cannot ask for wiki')
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

// return using alias or name (will first use alias)
pub fn (mut config ConfigRoot) site_wiki_get(name string) ?SiteConfig {
	mut name2 := name.to_lower()
	if name2.starts_with('wiki_') {
		name2 = name2[5..]
	}
	if name2.starts_with('www_') {
		return error('cannot ask for www')
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

// return using alias or name (will first use alias)
pub fn (mut config ConfigRoot) sites_get() []SiteConfig {
	mut sites := []SiteConfig{}
	for site in config.sites {
		path := site.path_code
		if os.exists(path) {
			sites << site
		}
	}
	return sites
}

pub fn (config ConfigRoot) reponame(name string) ?string {
	mut site := config.site_get(name) or { return error('Cannot find site with configname: $name') }
	return site.reponame()
}
