module publishingtools

import os

struct SiteConfig {
	//name of the wiki site
	name	string
	//depends on which other wiki sites
	depends []string
}


// remember the image, so we know if we have duplicates
fn (mut site Site) remember_image(path string, name string) {
	mut namelower := name_fix(name)
	mut pathfull := os.join_path(path, name)
	// now remove the root path
	pathrelative := pathfull[site.path.len..]
	// println( " - Image $pathfull" )
	if namelower in site.images {
		// error there should be no duplicates
		mut duplicatepath := site.images[namelower].path
		site.errors << SiteError{
			path: pathrelative
			error: 'duplicate image $duplicatepath'
			cat: SiteErrorCategory.duplicateimage
		}
	} else {
		site.images[namelower] = Image{
			path: pathrelative
		}
		// image := site.images[namelower]
		// println(image)
	}
}

fn (mut site Site) remember_page(path string, name string) {
	mut pathfull := os.join_path(path, name)
	pathrelative := pathfull[site.path.len..]
	mut namelower := name_fix(name)
	// println( " - Page $pathfull" )
	if namelower in site.pages {
		// error there should be no duplicates
		mut duplicatepath := site.pages[namelower].path
		site.errors << SiteError{
			path: pathrelative
			error: 'duplicate page $duplicatepath'
			cat: SiteErrorCategory.duplicatepage
		}
	} else {
		site.pages[namelower] = Page{
			path: pathrelative
		}
		// page := site.pages[namelower]
		// println(page)
	}
}

fn (mut site Site) check(){
	// if site.pages
	panic("S")

}

fn (mut site Site) process_files(path string) ? {
	// mut ret_err := ''
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
			site.process_files(os.join_path(path, item))
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
					site.remember_page(path, item)
				}
				if ext2 in ['jpg', 'png'] {
					site.remember_image(path, item)
				}
			}
		}
	}
}
