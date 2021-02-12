module publisher

import os

// the factory, get your tools here
// use path="" if you want to go from os.home_dir()/code/
// will find all wiki's
pub fn new(path string) ?Publisher {
	mut publisher := Publisher{}
	publisher.gitlevel = 0
	publisher.load_all(path.replace('~', os.home_dir())) ?
	return publisher
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


// returns the found locations for the sites, will return [[name,path]]
pub fn (mut publisher Publisher) site_locations_get() [][]string {
	mut res := [][]string{}
	for site in publisher.sites {
		res << [site.name, site.path]
	}
	return res
}


