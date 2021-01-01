module publisher

import os
import json

// the factory, get your tools here
pub fn new() Publisher {
	mut publisher := Publisher{}
	mut domain := os.getenv('DOMAIN')
	if domain == '' {
		domain = 'http://localhost:8082'
	}
	publisher.domain = domain
	publisher.gitlevel = 0
	return publisher
}

// load a site into the publishing tools
// name of the site needs to be unique
pub fn (mut publisher Publisher) load(name string, path string) {
	sitename := name_fix(name)
	path2 := path.replace('~', os.home_dir())
	println('load publisher: $path2')
	if !publisher.site_exists(sitename) {
		publisher.sites << Site{
			publisher: &publisher
			path: path2
			name: sitename
		}
	} else {
		panic("should not load on same name 2x: '$sitename'")
	}
	mut site := publisher.site_get(sitename) or { panic('cannot find site $sitename') }
	if !publisher.lazy_loading {
		site.files_process()
	}
}

pub fn (mut publisher Publisher) site_exists(name string) bool {
	pagename := name_fix(name)
	for site in publisher.sites {
		if pagename == site.name {
			return true
		}
	}
	return false
}

pub fn (mut publisher Publisher) site_get(name string) ?Site {
	pagename := name_fix(name)
	for site in publisher.sites {
		if pagename == site.name {
			return site
		}
	}
	return error('cannot find site: $pagename')
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
	pagename := name_fix(name)
	splitted := pagename.split(':')
	if splitted.len == 1 {
		return '', pagename
	} else if splitted.len == 2 {
		return splitted[0], splitted[1]
	} else {
		return error("name needs to be in format 'sitename:imagename' or 'imagename', now '$pagename'")
	}
}

pub fn (mut publisher Publisher) page_exists(name string) bool {
	publisher.page_get(name) or { return false }
	return true
}

// name in form: 'sitename:pagename' or 'pagename'
pub fn (mut publisher Publisher) page_get(name string) ?Page {
	// println('page_get: $name')
	sitename, pagename := site_page_names_get(name) ?
	if sitename != '' {
		site := publisher.site_get(sitename) ?
		page := site.page_get(pagename) ?
		return page
	} else {
		mut res := []Page{}
		for site in publisher.sites {
			page := site.page_get(pagename) or { continue }
			res << page
		}
		if res.len == 1 {
			return res[0]
		} else if res.len > 1 {
			return error("More than 1 page has name, cannot figure out which one: '$pagename'")
		} else {
			return error("Could not find page: '$pagename'")
		}
	}
}

// CANT WE USE A GENERIC HERE???
// name in form: 'sitename:imagename' or 'imagename'
pub fn (mut publisher Publisher) image_get(name string) ?Image {
	sitename, imagename := site_page_names_get(name) ?
	if sitename != '' {
		site := publisher.site_get(sitename) ?
		image := site.image_get(imagename) ?
		return image
	} else {
		mut res := []Image{}
		for site in publisher.sites {
			image := site.image_get(imagename) or { continue }
			res << image
		}
		if res.len == 1 {
			return res[0]
		} else if res.len > 1 {
			return error("More than 1 image has name, cannot figure out which one: '$imagename'")
		} else {
			return error("Could not find image: '$imagename'")
		}
	}
}

pub fn (mut publisher Publisher) image_exists(name string) bool {
	publisher.image_get(name) or { return false }
	return true
}

// check all pages, try to find errors
pub fn (mut publisher Publisher) check() {
	for site in publisher.sites {
		for mut page in site.pages {
			page.check(site)
		}
		for mut image in site.images {
			image.process(site)
		}
	}
}

pub fn (mut publisher Publisher) load_all() {
	publisher.gitlevel = -2 // we do this gitlevel to make sure we don't go too deep in the directory level
	publisher.load_all_private('')
}

// find all wiki's, this goes very fast, no reason to cache
fn (mut publisher Publisher) load_all_private(path string) {
	mut path1 := ''
	if path == '' {
		path1 = '$os.home_dir()/code/'
	} else {
		path1 = path
	}
	items := os.ls(path1) or { panic('cannot find $path1') }
	publisher.gitlevel++
	for item in items {
		pathnew := os.join_path(path1, item)
		if os.is_dir(pathnew) {
			// println(" - $pathnew '$item' ${publisher.gitlevel}")		
			if os.is_link(pathnew) {
				continue
			}
			if os.exists(os.join_path(pathnew, 'wikiconfig.json')) {
				content := os.read_file(os.join_path(pathnew, 'wikiconfig.json')) or {
					panic('Failed to load json ${os.join_path(pathnew, 'wikiconfig.json')}')
				}
				config := json.decode(SiteConfig, content) or {
					// eprintln()
					panic('Failed to decode json ${os.join_path(pathnew, 'wikiconfig.json')}')
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
