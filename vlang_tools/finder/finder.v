module finder

import os
// import json


struct Data {
	pub mut:
		sites map[string]Site
}

struct Site{
	pub mut:
		path 	string
		images	map[string]Image
		pages	map[string]Page

}

pub enum ImageStatus { unknown ok error }
struct Image {
	path 	string
	state 	ImageStatus
	nrtimes_used int
}

pub enum PageStatus { unknown ok error }
struct Page {
	path 	string
	state 	PageStatus
	errors []PageError
	nrtimes_inluded int
	nrtimes_linked 	int
}

struct PageError {
	line	string
	linenr 	int
	error	string
}


//remember the image, so we know if we have duplicates
fn (mut site Site) remember_image(path string, name string){
	mut namelower := name.to_lower()
	mut pathfull := os.join_path(path, name)
	// println( " - Image $pathfull" )
	site.images[name] = Image({ path: pathfull})
	image := site.images[namelower]
	println(image)

}

fn (mut site Site) remember_page(path string, name string){

	mut pathfull := os.join_path(path, name)
	// println( " - Page $pathfull" )

}

//process the markdown content and include other files, find links, ...
fn (mut page Page) process(){

	contents := os.read_file(page.path) or {
		println('Failed to open ${page.path}')
		return
	}

	for line in contents.split_into_lines() {
			println (line)
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

pub fn (mut data Data) load(name string, path string) {	
	// fpath := code_path_get()
    // configdata := os.read_file(fpath) or {return}
    // conf2 := json.decode(Application, configdata) or {
    //     panic('Failed to parse json for $fpath')
    // }
	// conf.platform = conf2.platform
    // for lang in languages_arr {
    //     l.m[lang.ext] = lang
    // }
	mut path2 := path.replace("~",os.home_dir())
	println("load finder: $path2")
	data.sites[name] = Site({path:path2})
	data.sites[name].process_files(path2)
}

pub fn get() Data{
	mut data := Data{}
	return data
}