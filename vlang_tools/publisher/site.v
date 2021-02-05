module publisher

import os

// remember the file, so we know if we have duplicates
fn (mut site Site) file_remember(path string, name string, mut publisher Publisher) ? {
	mut namelower := site.name_fix_alias(name)
	mut pathfull_fixed := os.join_path(path, namelower)
	mut pathfull := os.join_path(path, name)
	if pathfull_fixed != pathfull {
		os.mv(pathfull, pathfull_fixed) or { panic(err) }
		pathfull = pathfull_fixed
	}
	// now remove the root path
	pathrelative := pathfull[site.path.len..]
	// println(' - File $namelower <- $pathfull')
	if site.file_exists(namelower) {
		// error there should be no duplicates
		site.errors << SiteError{
			path: pathrelative
			error: 'duplicate file $pathrelative'
			cat: SiteErrorCategory.duplicatefile
		}
	} else {
		if publisher.files.len == 0 {
			publisher.files = []File{}
		}

		file := File{
			id: publisher.files.len
			site_id: site.id
			name: namelower
			path: pathrelative
		}
		// println("remember site: $file.name")
		publisher.files << file
		site.files[namelower] = publisher.files.len - 1
	}
}

fn (mut site Site) page_remember(path string, name string, mut publisher Publisher) ? {
	mut namelower := site.name_fix_alias(name)
	mut pathfull := os.join_path(path, name)
	mut pathfull_fixed := os.join_path(path, namelower) + '.md'
	if pathfull_fixed != pathfull {
		os.mv(pathfull, pathfull_fixed) or { panic(err) }
		pathfull = pathfull_fixed
	}
	pathrelative := pathfull[site.path.len..]
	if site.page_exists(namelower) {
		site.errors << SiteError{
			path: pathrelative
			error: 'duplicate page $pathrelative'
			cat: SiteErrorCategory.duplicatepage
		}
	} else {
		if publisher.pages.len == 0 {
			publisher.pages = []Page{}
		}

		publisher.pages << Page{
			id: publisher.pages.len
			site_id: site.id
			name: namelower
			path: pathrelative
		}
		site.pages[namelower] = publisher.pages.len - 1
	}
}

pub fn (mut site Site) reload(mut publisher Publisher) {
	site.state = SiteState.init
	site.pages = map[string]int{}
	site.files = map[string]int{}
	site.errors = []SiteError{}
	site.files_process(mut publisher) or { panic(err) }
	site.load(mut publisher)
}

pub fn (mut site Site) load(mut publisher Publisher) {
	if site.state == SiteState.ok {
		return
	}

	if site.pages.len == 0 {
		site.files_process(mut publisher) or { panic(err) }
	}

	imgnotusedpath := site.path + '/img_notused'
	if !os.exists(imgnotusedpath) {
		os.mkdir(imgnotusedpath) or { panic(err) }
	}
	imgdoubleusedpath := site.path + '/img_multiple_use'
	if !os.exists(imgdoubleusedpath) {
		os.mkdir(imgdoubleusedpath) or { panic(err) }
	}
	// if site.pages
	for _, id in site.pages {
		mut p := publisher.page_get_by_id(id) or {
			eprintln(err)
			continue
		}

		p.process(mut publisher) or { panic(err) }
	}
	for _, id in site.files {
		mut f := publisher.file_get_by_id(id) or {
			eprintln(err)
			continue
		}
		f.process(mut publisher)
	}
}

// process files in the site (find all files)
pub fn (mut site Site) files_process(mut publisher Publisher) ? {
	if !os.exists(site.path) {
		return error("cannot find site on path:'$site.path'")
	}
	return site.files_process_recursive(site.path, mut publisher)
}

fn (mut site Site) files_process_recursive(path string, mut publisher Publisher) ? {
	items := os.ls(path) ?
	for item in items {
		if os.is_dir(os.join_path(path, item)) {
			if item.starts_with('.') {
				continue
			} else if item.starts_with('_') {
				continue
			} else {
				site.files_process_recursive(os.join_path(path, item), mut publisher) ?
			}
		} else {
			if item.starts_with('.') {
				continue
			} else if item.starts_with('_') {
				continue
			} else {
				// for names we do everything case insensitive
				mut itemlower := item.to_lower()
				mut ext := os.file_ext(itemlower)
				if ext != '' {
					// only process files which do have extension
					ext2 := ext[1..]
					if ext2 == 'md' {
						site.page_remember(path, item, mut publisher) ?
					}
					if ext2 in ['jpg', 'png', 'svg', 'jpeg', 'gif'] {
						site.file_remember(path, item, mut publisher) ?
					}
				}
			}
		}
	}
}
