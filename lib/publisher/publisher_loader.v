module publishermod

import os
import json
import myconfig


// use path="" if you want to go from os.home_dir()/code/	
fn (mut publisher Publisher) find_sites(path string) ? {
	publisher.gitlevel = -2 // we do this gitlevel to make sure we don't go too deep in the directory level
	publisher.find_sites_recursive(path) ?
}


///////////////////////////////////////////////////////// INTERNAL BELOW ////////////////
/////////////////////////////////////////////////////////////////////////////////////////


// load a site into the publishing tools
// name of the site needs to be unique
fn (mut publisher Publisher) load_site(config SiteConfig, path string) ? {
	mut cfg := myconfig.get()?	
	sitename := name_fix(config.name)
	mut _ := cfg.site_get(sitename) or {
		return error("$cfg\n -- ERROR: sitename in config file ($sitename) on repo in git, does not correspond with configname publishtools config.")
	}
	path2 := path.replace('~', os.home_dir())
	println(' - load publisher: $sitename - $path2')
	if !publisher.site_exists(sitename) {
		id := publisher.sites.len
		mut site := Site{
			id: id
			path: path2
			name: sitename
		}
		site.config = config
		publisher.sites << site
		publisher.site_names[sitename] = id
	} else {
		return error("should not load on same name 2x: '$sitename'")
	}
}

// find all wiki's, this goes very fast, no reason to cache
fn (mut publisher Publisher) find_sites_recursive(path string) ? {
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
			// is the template of vlangtools itself, should not go in there
			if pathnew.contains('vlang_tools/templates') {
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
				publisher.load_site(config, pathnew) or { panic(err) }
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
			publisher.find_sites_recursive(pathnew) or { panic(err) }
		}
	}
	publisher.gitlevel--
}
