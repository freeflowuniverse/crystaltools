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

//return code path for wiki
pub fn (mut config ConfigRoot) path_code_wiki_get(name string)? string {
	config_site := config.site_wiki_get(name)?
	return "${config.paths.code}/${config_site.name}"
}

pub fn (mut config ConfigRoot) path_publish_wiki_get(name string)? string {
	config_site := config.site_wiki_get(name)?
	return "${config.paths.publish}/wiki_${config_site.alias}"
}

//return code path for web
pub fn (mut config ConfigRoot) path_code_web_get(name string)? string {
	config_web := config.site_web_get(name)?
	return "${config.paths.code}/${config_web.name}"
}

pub fn (mut config ConfigRoot) path_publish_web_get(name string)? string {
	config_web := config.site_web_get(name)?
	return "${config.paths.publish}/www_${config_web.alias}"
}