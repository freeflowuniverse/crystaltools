module publisher

import os
import json

// the factory, get your tools here
// use path="" if you want to go from os.home_dir()/code/
// will find all wiki's
pub fn new(path string) ?Publisher {
	mut publisher := Publisher{}
	publisher.gitlevel = 0
	publisher.load_all(path.replace('~', os.home_dir())) ?
	return publisher
}

// load a site into the publishing tools
// name of the site needs to be unique
fn (mut publisher Publisher) load(config SiteConfig, path string) ? {
	sitename := name_fix(config.name)
	path2 := path.replace('~', os.home_dir())
	println(' - load publisher: $path2')
	if !publisher.site_exists(sitename) {
		id := publisher.sites.len
		mut site := Site{
			id: id
			path: path2
			name: sitename
		}
		site.config = config
		site.replace_init() ? // make sure we init the replace arguments
		publisher.sites << site
		publisher.site_names[sitename] = id
	} else {
		return error("should not load on same name 2x: '$sitename'")
	}
}

// make sure that the names are always normalized so its easy to find them back
pub fn name_fix(name string) string {
	mut pagename := name_fix_keepext(name)
	if pagename.ends_with('.md') {
		pagename = pagename[0..pagename.len - 3]
	}
	return pagename
}

pub fn name_fix_keepext(name string) string {
	mut pagename := name.to_lower()
	if '#' in pagename {
		pagename = pagename.split('#')[0]
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
	mut pagename := name.trim(' ')
	if pagename.starts_with('file__') || pagename.starts_with('page__') {
		pagename = pagename[6..]
		sitename := pagename.split('__')[0]
		itemname := pagename.split('__')[1]
		pagename = '$sitename:$itemname'
	}
	// to deal with things like "img/tf_world.jpg ':size=300x160'"
	splitted0 := pagename.split(' ')
	if splitted0.len > 0 {
		pagename = splitted0[0]
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

// use path="" if you want to go from os.home_dir()/code/
fn (mut publisher Publisher) load_all(path string) ? {
	publisher.gitlevel = -2 // we do this gitlevel to make sure we don't go too deep in the directory level
	publisher.load_all_private(path) ?
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
				publisher.load(config, pathnew) or { panic(err) }
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
			publisher.load_all_private(pathnew) or { panic(err) }
		}
	}
	publisher.gitlevel--
}

// returns the found locations for the sites, will return [[name,path]]
pub fn (mut publisher Publisher) site_locations_get() [][]string {
	mut res := [][]string{}
	for site in publisher.sites {
		res << [site.name, site.path]
	}
	return res
}

struct PublisherErrors {
pub mut:
	site_errors []SiteError
	page_errors map[string][]PageError
}

// destination is the destination path for the flatten operation
pub fn (mut publisher Publisher) flatten(destination string) {
	println(' - flatten wiki to $destination')

	mut errors := PublisherErrors{}
	mut dest_file := ''

	publisher.check() // makes sure we checked all

	for mut site in publisher.sites {
		errors = PublisherErrors{}

		site.files_process(mut publisher) or { panic(err) }

		// src_path[site.id] = site.path
		mut dest_dir := '$destination/$site.name'
		// dest_path[site.id] = dest

		// collect all errors in a datastruct
		for err in site.errors {
			// errors.site_errors << err
			// TODO: clearly not ok, the duplicates files check is not there
			if err.cat != SiteErrorCategory.duplicatefile
				&& err.cat != SiteErrorCategory.duplicatepage {
				errors.site_errors << err
			}
		}

		for name, _ in site.pages {
			page := site.page_get(name, mut publisher) or { panic(err) }
			if page.errors.len > 0 {
				errors.page_errors[name] = page.errors
			}
		}

		if !os.exists(dest_dir) {
			os.mkdir_all(dest_dir) or { panic(err) }
		}
		// write the json errors file
		os.write_file('$dest_dir/errors.json', json.encode(errors)) or { panic(err) }

		mut special := ['readme.md', 'README.md', '_sidebar.md', 'index.html', '_navbar.md']

		for file in special {
			dest_file = file
			if os.exists('$site.path/$file') {
				if dest_file.starts_with('_') {
					dest_file = dest_file[1..] // remove the _
				}
				os.cp('$site.path/$file', '$dest_dir/$dest_file') or { panic(err) }
			}
		}

		for name, _ in site.pages {
			mut page := site.page_get(name, mut publisher) or { panic(err) }
			content := page.content
			dest_file = os.join_path(dest_dir, os.file_name(page.path))
			os.write_file(dest_file, content) or { panic(err) }
		}

		for name, _ in site.files {
			mut fileobj := site.file_get(name, mut publisher) or { panic(err) }
			dest_file = os.join_path(dest_dir, os.file_name(fileobj.path))
			os.cp(fileobj.path_get(mut publisher), dest_file) or { panic(err) }
		}
	}
}
