module publisher

import os

struct SiteConfig {
	// name of the wiki site
	name    string
	// depends on which other wiki sites
	depends []string
}

fn (site Site) page_get(name string) ?&Page {
	mut namelower := name_fix(name)
	for item in site.pages {
		println('pageget: $site.name $namelower $item.name')
		if item.name == namelower {
			return item
		}
	}
	return error('cannot find page with name $name')
}

fn (site Site) image_get(name string) ?&Image {
	mut namelower := name_fix(name)
	for item in site.images {
		// println('name search: $item.name $namelower')
		if item.name == namelower {
			return item
		}
	}
	return error('cannot find image with name $name')
}

fn (site Site) page_exists(name string) bool {
	for item in site.pages {
		if item.name == name {
			return true
		}
	}
	return false
}

fn (site Site) image_exists(name string) bool {
	for item in site.images {
		if item.name == name {
			return true
		}
	}
	return false
}

// remember the image, so we know if we have duplicates
fn (mut site Site) image_remember(path string, name string) {
	mut namelower := name_fix(name)
	mut pathfull := os.join_path(path, name)
	// now remove the root path
	pathrelative := pathfull[site.path.len..]
	// println(' - Image $namelower <- $pathfull')
	if site.image_exists(namelower) {
		// error there should be no duplicates
		image := site.image_get(namelower) or {
			panic('BUG: should have been able to find image $namelower')
		}
		mut duplicatepath := image.path
		site.errors << SiteError{
			path: pathrelative
			error: 'duplicate image $duplicatepath'
			cat: SiteErrorCategory.duplicateimage
		}
	} else {
		site.images << &Image{
			name: namelower
			path: pathrelative
		}
	}
}

fn (mut site Site) page_remember(path string, name string) {
	mut pathfull := os.join_path(path, name)
	pathrelative := pathfull[site.path.len..]
	mut namelower := name_fix(name)
	if site.page_exists(namelower) {
		// error there should be no duplicates
		page := site.page_get(namelower) or {
			panic('BUG: should have been able to find page $namelower')
		}
		mut duplicatepath := page.path
		site.errors << SiteError{
			path: pathrelative
			error: 'duplicate page $duplicatepath'
			cat: SiteErrorCategory.duplicatepage
		}
	} else {
		site.pages << &Page{
			name: namelower
			path: pathrelative
		}
	}
}

fn (mut site Site) check() {
	// if site.pages
	panic('S')
}

// process files in the site
fn (mut site Site) files_process() ? {
	println('FILES LOAD FOR : $site.name')
	return site.files_process_recursive(site.path)
}

fn (mut site Site) files_process_recursive(path string) ? {
	items := os.ls(path) ?
	for item in items {
		if os.is_dir(os.join_path(path, item)) {
			mut basedir := os.file_name(path)
			if basedir.starts_with('.') {
				continue
			}
			if basedir.starts_with('_') {
				continue
			}
			site.files_process_recursive(os.join_path(path, item))
			continue
		} else {
			if item.starts_with('.') {
				continue
			}
			if item.starts_with('_') {
				continue
			}
			// for names we do everything case insensitive
			mut itemlower := item.to_lower()
			mut ext := os.file_ext(itemlower)
			if ext != '' {
				// only process files which do have extension
				ext2 := ext[1..]
				if ext2 == 'md' {
					site.page_remember(path, item)
				}
				if ext2 in ['jpg', 'png'] {
					site.image_remember(path, item)
				}
			}
		}
	}
}
