module publisher

import os
import json

// the factory, get your tools here
//use path="" if you want to go from os.home_dir()/code/
//will find all wiki's
pub fn new(path string) ?Publisher {
	mut publisher := Publisher{}
	publisher.gitlevel = 0
	publisher.load_all(path.replace('~', os.home_dir()))?
	return publisher
}

// load a site into the publishing tools
// name of the site needs to be unique
fn (mut publisher Publisher) load(name string, path string) ? {
	sitename := name_fix(name)
	path2 := path.replace('~', os.home_dir())
	println('load publisher: $path2')
	if !publisher.site_exists(sitename) {
		id := publisher.sites.len 
		mut site := Site{
			id: id
			path: path2
			name: sitename
		}
		publisher.sites << site
		publisher.site_names[sitename] = id
	} else {
		return error("should not load on same name 2x: '$sitename'")
	}
}


// make sure that the names are always normalized so its easy to find them back
pub fn name_fix(name string) string {
	mut pagename := name.to_lower()
	if pagename.ends_with('.md') {
		pagename = pagename[0..pagename.len - 3]
	}
	pagename = pagename.replace(' ', '_')
	pagename = pagename.replace('-', '_')
	pagename = pagename.replace('__', '_')
	pagename = pagename.replace('__', '_') // needs to be 2x because can be 3 to 2 to 1
	pagename = pagename.replace(';', ':')
	pagename = pagename.replace('::', ':')
	pagename = pagename.trim(' .:')
	return pagename
}

// return (sitename,pagename)
pub fn site_page_names_get(name string) ?(string, string) {
	mut pagename := name
	if pagename.starts_with('file__') || pagename.starts_with('page__'){
		pagename = pagename[6..]
		sitename := pagename.split("__")[0]
		itemname := pagename.split("__")[1]
		pagename = "$sitename:$itemname"
	}
	pagename = name_fix(pagename)
	splitted := pagename.split(':')
	if splitted.len == 1 {
		return '', pagename
	} else if splitted.len == 2 {
		return splitted[0], splitted[1]
	} else {
		return error("name needs to be in format 'sitename:filename' or 'filename', now '$pagename'")
	}
}


// check all pages, try to find errors
pub fn (mut publisher Publisher) check() {
	for mut site in publisher.sites {
		site.load(mut publisher)
	}
}

//use path="" if you want to go from os.home_dir()/code/
fn (mut publisher Publisher) load_all(path string) ? {
	publisher.gitlevel = -2 // we do this gitlevel to make sure we don't go too deep in the directory level
	publisher.load_all_private(path)?
}

// find all wiki's, this goes very fast, no reason to cache
fn (mut publisher Publisher) load_all_private(path string) ? {
	mut path1 := ''
	if path == '' {
		path1 = '$os.home_dir()/code/'
	} else {
		path1 = path
	}

	items := os.ls(path1) or { return error('cannot find $path1') }
	publisher.gitlevel++
	for item in items {
		pathnew := os.join_path(path1, item)
		if os.is_dir(pathnew) {
			// println(" - $pathnew '$item' ${publisher.gitlevel}")
			if os.is_link(pathnew) {
				continue
			}
			//is the template of vlangtools itself, should not go in there
			if pathnew.contains("vlang_tools/templates"){
				continue
			}			
			if os.exists(os.join_path(pathnew, 'wikiconfig.json')) {
				content := os.read_file(os.join_path(pathnew, 'wikiconfig.json')) or {
					return error('Failed to load json ${os.join_path(pathnew, 'wikiconfig.json')}')
				}
				config := json.decode(SiteConfig, content) or {
					// eprintln()
					return error('Failed to decode json ${os.join_path(pathnew, 'wikiconfig.json')}')
				}
				publisher.load(config.name, pathnew)
				continue
			}
			if item == '.git' {
				publisher.gitlevel = 0
				continue
			}
			if publisher.gitlevel > 1 {
				continue
			}
			if item.starts_with('.') {
				continue
			}
			if item.starts_with('_') {
				continue
			}
			publisher.load_all_private(pathnew)
		}
	}
	publisher.gitlevel--
}

//returns the found locations for the sites, will return [[name,path]]
pub fn (mut publisher Publisher) site_locations_get() [][]string {
	mut res := [][]string{}
	for site in publisher.sites {
		res << [site.name, site.path]
	}
	return res
}