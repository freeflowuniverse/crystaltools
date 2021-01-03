module publisher

import os
import json

// the factory, get your tools here
//use path="" if you want to go from os.home_dir()/code/
//will find all wiki's
pub fn new(path string) ?Publisher {
	mut publisher := Publisher{}
	mut domain := os.getenv('DOMAIN')
	if domain == '' {
		domain = 'http://localhost:8082'
	}
	publisher.gitlevel = 0
	publisher.load_all(path)?
	return publisher
}

// load a site into the publishing tools
// name of the site needs to be unique
fn (mut publisher Publisher) load(name string, path string) ? {
	sitename := name_fix(name)
	path2 := path.replace('~', os.home_dir())
	println('load publisher: $path2')
	if !publisher.site_exists(sitename) {
		mut site := Site{
			id: publisher.sites.len 
			path: path2
			name: sitename
		}
		publisher.sites << site
	} else {
		return error("should not load on same name 2x: '$sitename'")
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

pub fn (mut publisher Publisher) site_get(name string) ?&Site {
	pagename := name_fix(name)
	for site in publisher.sites {
		if pagename == site.name {
			// println('found site "$site.name"')
			mut site2:= &publisher.sites[site.id]
			if site2.pages.len == 0{
				//this is to make sure we have read the files from the filesystem if that was not done yet
				site2.files_process()?
				
			}
			return site2
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
pub fn (mut publisher Publisher) page_get(name string) ?(&Site, &Page) {
	// println('page_get: $name')
	sitename, pagename := site_page_names_get(name) ?
	// println("find $name in nr sites ${publisher.sites.len}")
	for site in publisher.sites {
		// println("find $name -> site:$site.name")
		if (sitename != "" && site.name == sitename) || sitename==""{
			for page in site.pages {
				// println("find $pagename -> page:$page.name")
				if page.name == pagename {
					// println("find $pagename -> FOUND")
					return &publisher.sites[site.id], &publisher.sites[site.id].pages[page.id]
				}
			}
		}
	}
	return error("Could not find page: '$pagename'")
}

// name in form: 'sitename:imagename' or 'imagename'
pub fn (mut publisher Publisher) image_get(name string) ?(&Site, &Image) {
	sitename, imagename := site_page_names_get(name) ?
	// println('get sitename:$sitename and imagename:$imagename')
	for site in publisher.sites {
		// println("find $name -> site:$site.name")
		if (sitename != "" && site.name == sitename) || sitename==""{
			// println("sitename:$sitename $site.images")
			for image in site.images {
				// println("find $sitename -> page:$image.name")
				if image.name == imagename {
					// println("find $sitename -> FOUND")
					return &publisher.sites[site.id], &publisher.sites[site.id].images[image.id]
				}
			}
		}
	}
	return error("Could not find image: '$imagename'")
}

pub fn (mut publisher Publisher) image_exists(name string) bool {
	publisher.image_get(name) or { return false }
	return true
}

// check all pages, try to find errors
pub fn (mut publisher Publisher) check() {
	for site in publisher.sites {
		site.check(mut publisher)
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