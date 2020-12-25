module publishingtools

import os
import json

struct PublTools {
mut:
	gitlevel int
pub mut:
	domain string
	sites map[string]Site
}


// the factory, get your tools here
pub fn new() PublTools {
	mut publtools := PublTools{}
	mut domain := os.getenv("DOMAIN")
	if domain == "" {
		domain = "http://localhost:8082"
	}
	publtools.domain = domain
	publtools.gitlevel = 0
	return publtools
}

pub fn (mut publtools PublTools) load(name string, path string) {
	name_lower := name_fix(name)
	path2 := path.replace('~', os.home_dir())
	println('load publishingtools: $path2')
	if name_lower !in publtools.sites {
		publtools.sites[name_lower] = Site{
			path: path2
			name: name_lower
		}
	} else {
		panic("should not load on same name 2x: '$name_lower'")
	}
	// publtools.sites[name_lower].process_files(path2)
}



pub fn (mut publtools PublTools) site_get(name string) ?Site {
	name_lower := name_fix(name)
	if name_lower in publtools.sites {
		return publtools.sites[name_lower]
	} else {
		return error('cannot find site: $name_lower')
	}
}

// make sure that the names are always normalized so its easy to find them back
pub fn name_fix(name string) string {
	mut name_lower := name.to_lower()
	if name_lower.ends_with('.md') {
		name_lower = name_lower[0..name_lower.len - 3]
	}
	name_lower = name_lower.replace(' ', '_')
	name_lower = name_lower.replace('-', '_')
	name_lower = name_lower.replace('__', '_')
	name_lower = name_lower.replace('__', '_') // needs to be 2x because can be 3 to 2 to 1
	name_lower = name_lower.replace(';', ':')
	name_lower = name_lower.replace('::', ':')
	return name_lower
}

pub fn (mut publtools PublTools) page_exists(name string) bool {
	publtools.page_get(name) or { return false }
	return true
}

// name in form: 'sitename:pagename' or 'pagename'
pub fn (mut publtools PublTools) page_get(name string) ?PageActor {
	println('page_get: $name')
	mut name_lower := name_fix(name)
	if ':' in name_lower {
		splitted := name_lower.split(':')
		if splitted.len != 2 {
			return error("name needs to be in format 'sitename:pagename' or 'pagename', now '$name_lower'")
		}
		sitename := splitted[0]
		page_name := splitted[1]
		site := publtools.site_get(sitename) or { return error(err) }
		pageactor := site.pageactor_get(page_name, publtools) or { return error(err) }
		return pageactor
	} else {
		mut res := []PageActor{}
		for key in publtools.sites.keys() {
			mut site := publtools.sites[key]
			pageactor := site.pageactor_get(name_lower, publtools) or { continue }
			res << pageactor
		}
		if res.len == 1 {
			return res[0]
		} else if res.len > 1 {
			return error("More than 1 page has name, cannot figure out which one: '$name_lower'")
		} else {
			return error("Could not find page: '$name_lower'")
		}
	}
}

// CANT WE USE A GENERIC HERE???
// name in form: 'sitename:imagename' or 'imagename'
pub fn (mut publtools PublTools) image_get(name string) ?ImageActor {
	mut name_lower := name_fix(name)
	if ':' in name_lower {
		splitted := name_lower.split(':')
		if splitted.len != 2 {
			return error("name needs to be in format 'sitename:imagename' or 'imagename', now '$name_lower'")
		}
		sitename := splitted[0]
		name_lower = splitted[1]
		mut site := publtools.site_get(sitename) or { return error(err) }
		imageactor := site.imageactor_get(name_lower, publtools) or { return error(err) }
		return imageactor
	} else {
		mut res := []ImageActor{}
		for key in publtools.sites.keys() {
			mut site := publtools.sites[key]
			imageactor := site.imageactor_get(name_lower, publtools) or { continue }
			res << imageactor
		}
		if res.len == 1 {
			return res[0]
		} else if res.len > 1 {
			return error("More than 1 image has name, cannot figure out which one: '$name_lower'")
		} else {
			return error("Could not find image: '$name_lower'")
		}
	}
}

pub fn (mut publtools PublTools) image_exists(name string) bool {
	publtools.image_get(name) or { return false }
	return true
}

// check all pages, try to find errors
pub fn (mut publtools PublTools) check() {
	for sitename in publtools.sites.keys() {
		mut site := publtools.sites[sitename]
		for key in site.pages.keys() {
			mut page := site.pages[key]
			// not mutable
			mut pageactor := PageActor{
				page: &page
				site: &site
				publtools: publtools
			}
			pageactor.check()
		}
		// for key in site.images.keys(){
		// 	mut image := site.images[key]
		// 	mut imageactor := ImageActor{image:&image, site:&site, publtools:&publtools}
		// 	imageactor.process()
		// }		
	}
}


pub fn (mut  publtools PublTools) load_all() {
	publtools.gitlevel = -2 //we do this gitlevel to make sure we don't go too deep in the directory level
	publtools.load_all_private("")
}

//find all wiki's, this goes very fast, no reason to cache
fn (mut  publtools PublTools) load_all_private(path string) {
	mut path1 := ""
	// mut gitlevel1 := gitlevel
	if path == "" {
		path1 = "${os.home_dir()}/code/"
	}else{
		path1 = path
	}
	items := os.ls(path1) or { panic("cannot find $path1")}
	publtools.gitlevel ++
	for item in items {
		pathnew := os.join_path(path1, item)
		if os.is_dir(pathnew) {
			// println(" - $pathnew '$item' ${publtools.gitlevel}")		
			if os.is_link(pathnew){
				continue
			}
			if os.exists(os.join_path(pathnew, "wikiconfig.json")){
				content := os.read_file(os.join_path(pathnew, "wikiconfig.json")) or {panic('Failed to load json ${os.join_path(pathnew, "wikiconfig.json")}')}
				config := json.decode(SiteConfig, content )or {
					// eprintln()
					panic('Failed to decode json ${os.join_path(pathnew, "wikiconfig.json")}')
				}
				publtools.load(config.name,pathnew)
				continue
			}
			if item == '.git' {
				publtools.gitlevel = 0 				
				continue
			}
			if publtools.gitlevel > 1 {
				continue
			}
			if item.starts_with('.') {				
				continue
			}
			if item.starts_with('_') {
				continue
			}
			publtools.load_all_private(pathnew)
		}
	}	
	publtools.gitlevel --
}
