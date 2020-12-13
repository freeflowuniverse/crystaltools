module publishingtools

import os
// import json


struct PublTools {
	pub mut:
		sites map[string]Site
}


pub fn (mut publtools PublTools) load(name string, path string) {	
	mut name_lower := name_fix(name)
	mut path2 := path.replace("~",os.home_dir())
	println("load publishingtools: $path2")
	publtools.sites[name_lower] = Site{path:path2, name:name_lower}
	publtools.sites[name_lower].process_files(path2)
}

//the factory, get your tools here
pub fn new() PublTools{
	mut publtools := PublTools{}
	return publtools
}

pub fn (mut publtools PublTools) site_get(name string) Site{	
	name_lower := name_fix(name)
	return publtools.sites[name_lower]
}

//make sure that the names are always normalized so its easy to find them back
fn name_fix(name string) string {	
	mut name_lower := name.to_lower()
	if name_lower.ends_with(".md"){
		name_lower = name_lower[0..name_lower.len-3]
	}
	name_lower = name_lower.replace(" ","_")
	name_lower = name_lower.replace("-","_")
	name_lower = name_lower.replace("__","_")
	name_lower = name_lower.replace("__","_") //needs to be 2x because can be 3 to 2 to 1
	name_lower = name_lower.replace(";","_")
	return name_lower
}


//name in form: 'sitename:pagename' or 'pagename'
pub fn (mut publtools PublTools) page_get(name string) ?PageActor {	
	mut name_lower := name_fix(name)
	if ":" in name_lower {
		splitted := name_lower.split(":")
		if splitted.len !=2 {
			return error("name needs to be in format 'sitename:pagename' or 'pagename', now '$name_lower'")
		}
		sitename := splitted[0]
		name_lower = splitted[1]
		mut site := publtools.site_get(sitename)
		pageactor := site.pageactor_get(name_lower, publtools) or {return error(err)}
		return pageactor
	}else{
		mut res := []PageActor{}
		for key in publtools.sites.keys(){
			mut site := publtools.sites[key]
			pageactor := site.pageactor_get(name_lower, publtools) or {continue}
			res << pageactor
		}
		if res.len==1 {
			return res[0]
		} else if res.len>1 {
			return error ("More than 1 page has name, cannot figure out which one: '$name_lower'")
		}else{
			return error ("Could not find page: '$name_lower'")
		}
	}	
}

//CANT WE USE A GENERIC HERE???

//name in form: 'sitename:imagename' or 'imagename'
pub fn (mut publtools PublTools) image_get(name string) ?ImageActor {	
	mut name_lower := name_fix(name)
	if ":" in name_lower {
		splitted := name_lower.split(":")
		if splitted.len !=2 {
			return error("name needs to be in format 'sitename:imagename' or 'imagename', now '$name_lower'")
		}
		sitename := splitted[0]
		name_lower = splitted[1]
		mut site := publtools.site_get(sitename)
		imageresult := site.imageactor_get(name_lower,publtools) or {return error(err)}
		return imageresult
	}else{
		mut res := []ImageActor{}
		for key in publtools.sites.keys(){
			mut site := publtools.sites[key]
			imageresult := site.imageactor_get(name_lower,publtools) or {continue}
			res << imageresult
		}
		if res.len==1 {
			return res[0]
		} else if res.len>1 {
			return error ("More than 1 image has name, cannot figure out which one: '$name_lower'")
		}else{
			return error ("Could not find image: '$name_lower'")
		}
	}	
}


pub fn (mut publtools PublTools) process() {
	for sitename in publtools.sites.keys(){
		mut site := publtools.sites[sitename]

		for key in site.pages.keys(){
			mut page := site.pages[key]
			//not mutable
			mut pageactor := PageActor{page:&page, site:&site, publtools:&publtools}
			pageactor.process()
		}	
		for key in site.images.keys(){
			mut image := site.images[key]
			mut imageactor := ImageActor{image:&image, site:&site, publtools:&publtools}
			imageactor.process()
		}		

		
	}	
}


// pub fn (mut site Site) process(publtools PublTools) {
// }

// pub fn (site Site) path_get(path string) string{	
// 	return os.join_path(site.path,path)
// }

