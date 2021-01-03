module publisher

import os

struct SiteConfig {
	// name of the wiki site
	name    string
	// depends on which other wiki sites
	depends []string
}

pub fn (site Site) page_get(name string) ?&Page {
	mut namelower := name_fix(name)
	for item in site.pages {
		// println('pageget: $site.name $namelower $item.name')
		if item.name == namelower {
			return &site.pages[item.id]
		}
	}
	return error('cannot find page with name $name')
}

pub fn (site Site) image_get(name string) ?&Image {
	mut namelower := name_fix(name)
	for item in site.images {
		// println('name search: $item.name $namelower')
		if item.name == namelower {
			return &site.images[item.id]
		}
	}
	return error('cannot find image with name $name')
}

pub fn (site Site) page_exists(name string) bool {
	for item in site.pages {
		if item.name == name {
			return true
		}
	}
	return false
}

pub fn (site Site) image_exists(name string) bool {
	for item in site.images {
		if item.name == name {
			return true
		}
	}
	return false
}

// remember the image, so we know if we have duplicates
fn (mut site Site) image_remember(path string, name string)? {
	mut namelower := name_fix(name)
	mut pathfull_fixed := os.join_path(path, namelower)
	mut pathfull := os.join_path(path, name)
	if pathfull_fixed != pathfull{
		os.mv(pathfull,pathfull_fixed)
		pathfull = pathfull_fixed
	}
	// now remove the root path
	pathrelative := pathfull[site.path.len..]
	// println(' - Image $namelower <- $pathfull')
	if site.image_exists(namelower) {
		// error there should be no duplicates
		image := site.image_get(namelower) or {
			return error('BUG: should have been able to find image $namelower')
		}
		mut duplicatepath := image.path
		site.errors << SiteError{
			path: pathrelative
			error: 'duplicate image $duplicatepath'
			cat: SiteErrorCategory.duplicateimage
		}
	} else {
		image:= Image{
			id: site.images.len
			site_id: site.id
			name: namelower
			path: pathrelative
		}
		// println("remember site: $image.name")
		site.images << image
	}
}

fn (mut site Site) page_remember(path string, name string)? {
	mut namelower := name_fix(name)
	mut pathfull := os.join_path(path, name)+".md"
	mut pathfull_fixed := os.join_path(path, namelower)+".md"
	if pathfull_fixed != pathfull{
		os.mv(pathfull,pathfull_fixed)
		pathfull = pathfull_fixed
	}	
	pathrelative := pathfull[site.path.len..]	
	if site.page_exists(namelower) {
		// error there should be no duplicates
		page := site.page_get(namelower) or {
			return error('BUG: should have been able to find page $namelower')
		}
		mut duplicatepath := page.path
		site.errors << SiteError{
			path: pathrelative
			error: 'duplicate page $duplicatepath'
			cat: SiteErrorCategory.duplicatepage
		}
	} else {
		site.pages << Page{
			id: site.pages.len
			site_id: site.id
			name: namelower
			path: pathrelative
		}
	}
}

pub fn (site Site) check( mut publisher &Publisher) {

	imgnotusedpath := site.path+"/img_notused"
	if ! os.exists(imgnotusedpath){
		os.mkdir(imgnotusedpath)
	}
	imgdoubleusedpath := site.path+"/img_multiple_use"
	if ! os.exists(imgdoubleusedpath){
		os.mkdir(imgdoubleusedpath)
	}


	// if site.pages
	for mut page in site.pages {
		page = &publisher.sites[site.id].pages[page.id]
		page.check(mut publisher)
	}
	for mut image in site.images {
		image = &publisher.sites[site.id].images[image.id]
		image.process(mut publisher)
	}

}

// process files in the site
fn (mut site Site) files_process() ? {
	// println('FILES LOAD FOR : $site.name')
	// println("file path check: $site.path -> ${os.exists(site.path)}")
	if ! os.exists(site.path){return error("cannot find site on path:'$site.path'")}
	return site.files_process_recursive(site.path)
}

fn (mut site Site) files_process_recursive(path string) ? {
	items := os.ls(path) ?
	// println(items)
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
					site.page_remember(path, item)?
				}
				if ext2 in ['jpg', 'png'] {
					site.image_remember(path, item)?
				}
			}
		}
	}
}
