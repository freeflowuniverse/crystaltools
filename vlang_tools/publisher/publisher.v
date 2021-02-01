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
fn (mut publisher Publisher) load(config SiteConfig, path string) ? {
	sitename := name_fix(config.name)
	path2 := path.replace('~', os.home_dir())
	println('load publisher: $path2')
	if !publisher.site_exists(sitename) {
		id := publisher.sites.len 
		mut site := Site{
			id: id
			path: path2
			name: sitename
		}
		site.config = config
		site.replace_init()? //make sure we init the replace arguments
		publisher.sites << site
		publisher.site_names[sitename] = id
	} else {
		return error("should not load on same name 2x: '$sitename'")
	}
}


// make sure that the names are always normalized so its easy to find them back
pub fn name_fix(name string) string {
	mut pagename := name.to_lower()
	if "#" in pagename{
		pagename = pagename.split("#")[0]
	}
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
	mut pagename := name.trim(" ")
	if pagename.starts_with('file__') || pagename.starts_with('page__'){
		pagename = pagename[6..]
		sitename := pagename.split("__")[0]
		itemname := pagename.split("__")[1]
		pagename = "$sitename:$itemname"
	}
	//to deal with things like "img/tf_world.jpg ':size=300x160'"
	splitted0 := pagename.split(" ")
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
				publisher.load(config, pathnew) or {panic(err)}
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
			publisher.load_all_private(pathnew) or {panic(err)}
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

pub fn (mut publisher Publisher) flatten(base string){
	mut src_path := map[int]string
	mut dest_path := map[int]string
	mut files := map[string]string

	for mut site in publisher.sites {
		src_path[site.id] = site.path
		mut dest := "$base/$site.name"
		dest_path[site.id] = dest
		
		if !os.exists(dest){
			os.mkdir_all(dest) or {panic(err)}
		}

		
		if !os.exists(dest){
			os.mkdir_all(dest) or {panic(err)}
		}

		mut special := ["readme.md", "README.md", "_sidebar.md"]

		for file in special{
			if os.exists("$site.path/$file"){
				os.cp("$site.path/$file", "$dest/$file") or {panic(err)}
			}
		}
	}

	for mut file in publisher.files {
		mut path := file.path
		if path.contains("img_notused"){
			path = path.replace("img_notused", "img")
		}

		if path.contains("img_multiple_use"){
			path = path.replace("img_multiple_use", "img")
		}

		files[path] = "/" + os.file_name(file.path)
		mut src := os.join_path(src_path[file.site_id], file.path)
		mut dest := os.join_path(dest_path[file.site_id], os.file_name(file.path))
		os.cp(src, dest) or {panic(err)}
	}

	for mut page in publisher.pages {
		mut src := os.join_path(src_path[page.site_id], page.path)
		mut dest := os.join_path(dest_path[page.site_id], os.file_name(page.path))
		mut content :=  os.read_file(src) or {continue}

		for f_src, f_dest in files{
			content = content.replace(f_src, f_dest)
		}

		os.write_file(dest, content) or {panic(err)}
	}

}