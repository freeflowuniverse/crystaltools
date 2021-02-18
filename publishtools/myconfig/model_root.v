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
	port   int = 80
}

pub struct Paths {
pub mut:
	base    string
	code    string
	publish string
}

// NOT WORKING YET
// //return code path for wiki
// pub fn (mut config ConfigRoot) path_code_wiki_get(name string)? string {
// 	config_site := config.site_wiki_get(name)?
// 	return "${config.paths.code}/${config_site.name}"
// }

pub fn (mut config ConfigRoot) path_publish_wiki_get(name string) ?string {
	config_site := config.site_wiki_get(name) ?
	return '$config.paths.publish/wiki_$config_site.alias'
}

// NOT WORKING YET
// //return code path for web
// pub fn (mut config ConfigRoot) path_code_web_get(name string)? string {
// 	config_web := config.site_web_get(name)?
// 	return "${config.paths.code}/${config_web.name}"
// }

pub fn (mut config ConfigRoot) path_publish_web_get(name string) ?string {
	config_web := config.site_web_get(name) ?
	return '$config.paths.publish/$config_web.name'
}

pub fn (mut config ConfigRoot) path_publish_web_get_domain(domain string)? string {
	for s in config.sites{
		if domain in s.domains{
			return config.path_publish_web_get(s.alias)
		}
	}
	return error('Cannot find wiki site with domain: $domain')	
}

pub fn (mut config ConfigRoot) publish_web_get_name(domain string)? string {
	for s in config.sites{
		if domain in s.domains{
			return s.name
		}
	}
	return error('Cannot find wiki site with domain: $domain')	
}
