module finder

import os
// import json


struct Site{
	name 	string
	path 	string
	pub mut:
		images	map[string]Image
		pages	map[string]Page
		errors  []SiteError

}

pub enum SiteErrorCategory { duplicateimage duplicatepage}
struct SiteError {
	path 	string
	error	string
	cat 	SiteErrorCategory
}

//remember the image, so we know if we have duplicates
fn (mut site Site) remember_image(path string, name string){
	mut namelower := name_fix(name)
	mut pathfull := os.join_path(path, name)
	// now remove the root path
	pathfull = pathfull[site.path.len+1..]
	// println( " - Image $pathfull" )
	if namelower in site.images {
		//error there should be no duplicates
		mut duplicatepath := site.images[namelower].path
		site.errors << SiteError{path:pathfull, error:"duplicate image $duplicatepath", cat:SiteErrorCategory.duplicateimage}
	}else{
		site.images[namelower] = Image({ path: pathfull})
		// image := site.images[namelower]
		// println(image)
	}
}

fn (mut site Site) remember_page(path string, name string){

	mut pathfull := os.join_path(path, name)
	pathfull = pathfull[site.path.len+1..]
	mut namelower := name_fix(name)
	// println( " - Page $pathfull" )

	if namelower in site.pages {
		//error there should be no duplicates
		mut duplicatepath := site.pages[namelower].path
		site.errors << SiteError{path:pathfull, error:"duplicate page $duplicatepath", cat:SiteErrorCategory.duplicatepage}
	}else{
		site.pages[namelower] = Page({ path: pathfull})
		// page := site.pages[namelower]
		// println(page)
	}

}


fn (mut site Site) process_files(path string) ? {
	// mut ret_err := ''
	items := os.ls(path)?

	for item in items {
		if os.is_dir(os.join_path(path, item)) {
			mut basedir := os.file_name(path)
			if basedir.starts_with(".") {continue}
			if basedir.starts_with("_") {continue}		
			site.process_files(os.join_path(path, item))
			continue
		} else {
			if item.starts_with(".") {continue}
			if item.starts_with("_") {continue}
			//for names we do everything case insensitive
			mut itemlower := item.to_lower()
			mut ext := os.file_ext(itemlower)			
			if ext != "" {
				//only process files which do have extension
			 	ext2 := ext[1..]

				if ext2 == "md" {
					site.remember_page(path,item)
				}

				if ext2 in ["jpg","png"] {
					site.remember_image(path,item)
				}	
			}
		}
	}
}

pub fn (mut site Site) process() {
	for key in site.pages.keys(){
		site.pages[key].process(site)
	}	
	for key in site.images.keys(){
		site.images[key].process(site)
	}		
}

pub fn (site Site) path_get(path string) string{	
	return os.join_path(site.path,path)
}

struct PageResult {
	path string
	page Page
}

struct ImageResult {
	path string
	image Image
}


//return fullpath,pageobject
pub fn (site Site) page_get(name string) ?PageResult{	
	namelower := name_fix(name)
	if namelower in site.pages {
		page2 := site.pages[namelower]
		path2 := site.path_get(page2.path)
		return PageResult{path:path2, page:page2}
	}
	return error("Could not find page $namelower in site ${site.name}")
}

//return fullpath,imageobject
pub fn (site Site) image_get(name string) ?ImageResult{	
	namelower := name_fix(name)
	if namelower in site.images {
		image2 := site.images[namelower]
		path2 := site.path_get(image2.path)
		return ImageResult{path:path2, image:image2}
	}
	return error("Could not find image $namelower in site ${site.name}")
}