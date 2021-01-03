module publisher

import os

struct SiteConfig {
	// name of the wiki site
	name    string
	// depends on which other wiki sites
	depends []string
}



// remember the file, so we know if we have duplicates
fn (mut site Site) file_remember(path string, name string, mut publisher &Publisher)? {
	mut namelower := name_fix(name)
	mut pathfull_fixed := os.join_path(path, namelower)
	mut pathfull := os.join_path(path, name)
	if pathfull_fixed != pathfull{
		os.mv(pathfull,pathfull_fixed)
		pathfull = pathfull_fixed
	}
	// now remove the root path
	pathrelative := pathfull[site.path.len..]
	// println(' - File $namelower <- $pathfull')
	if site.file_exists(namelower) {
		// error there should be no duplicates
		file := site.file_get(namelower) or {
			return error('BUG: should have been able to find file $namelower')
		}
		mut duplicatepath := file.path
		site.errors << SiteError{
			path: pathrelative
			error: 'duplicate file $duplicatepath'
			cat: SiteErrorCategory.duplicatefile
		}
	} else {
		file:= File{
			// id: site.files.len
			site_id: site.id
			name: namelower
			path: pathrelative
		}
		// println("remember site: $file.name")
		publisher.files << file
		site.files[namelower]=site.files.len
	}
}

fn (mut site Site) page_remember(path string, name string, mut publisher &Publisher)? {
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
		page := site.page_get(namelower,mut publisher) or {
			return error('BUG: should have been able to find page $namelower')
		}
		mut duplicatepath := page.path
		site.errors << SiteError{
			path: pathrelative
			error: 'duplicate page $duplicatepath'
			cat: SiteErrorCategory.duplicatepage
		}
	} else {
		publisher.pages << Page{
			site_id: site.id
			name: namelower
			path: pathrelative
		}
		site.pages[namelower]=site.pages.len
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
	for mut file in site.files {
		file = &publisher.sites[site.id].files[file.id]
		file.process(mut publisher)
	}

}

// process files in the site
fn (mut site Site) files_process(mut publisher &Publisher) ? {
	// println('FILES LOAD FOR : $site.name')
	// println("file path check: $site.path -> ${os.exists(site.path)}")
	if ! os.exists(site.path){return error("cannot find site on path:'$site.path'")}
	return site.files_process_recursive(site.path,mut publisher)
}

fn (mut site Site) files_process_recursive(path string,mut publisher &Publisher) ? {
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
			site.files_process_recursive(os.join_path(path, item),mut publisher)
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
					site.page_remember(path, item, mut publisher)?
				}
				if ext2 in ['jpg', 'png'] {
					site.file_remember(path, item, mut publisher)?
				}
			}
		}
	}
}
