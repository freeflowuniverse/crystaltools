module publishingtools

import os
// import json


struct PublTools {
	pub mut:
		sites map[string]Site
}


pub fn (mut structure PublTools) load(name string, path string) {	
	// fpath := code_path_get()
    // configSites := os.read_file(fpath) or {return}
    // conf2 := json.decode(Application, configSites) or {
    //     panic('Failed to parse json for $fpath')
    // }
	// conf.platform = conf2.platform
    // for lang in languages_arr {
    //     l.m[lang.ext] = lang
    // }
	mut name_lower := name_fix(name)
	mut path2 := path.replace("~",os.home_dir())
	println("load publishingtools: $path2")
	structure.sites[name_lower] = Site({path:path2, name:name_lower})
	structure.sites[name_lower].process_files(path2)
}

pub fn get() PublTools{
	mut structure := PublTools{}
	return structure
}

pub fn (mut structure PublTools) site_get(name string) Site{	
	name_lower := name_fix(name)
	return structure.sites[name_lower]
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
pub fn (mut structure PublTools) page_get(name string) ?PageActor {	
	mut name_lower := name_fix(name)
	if ":" in name_lower {
		splitted := name_lower.split(":")
		if splitted.len !=2 {
			return error("name needs to be in format 'sitename:pagename' or 'pagename', now '$name_lower'")
		}
		sitename := splitted[0]
		name_lower = splitted[1]
		mut site := structure.site_get(sitename)
		pageactor := site.page_get(name_lower, structure) or {return error(err)}
		return pageactor
	}else{
		mut res := []PageActor
		for key in structure.sites.keys(){
			mut site := structure.sites[key]
			pageactor := site.page_get(name_lower, structure) or {continue}
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
pub fn (mut structure PublTools) image_get(name string) ?ImageActor {	
	mut name_lower := name_fix(name)
	if ":" in name_lower {
		splitted := name_lower.split(":")
		if splitted.len !=2 {
			return error("name needs to be in format 'sitename:imagename' or 'imagename', now '$name_lower'")
		}
		sitename := splitted[0]
		name_lower = splitted[1]
		mut site := structure.site_get(sitename)
		imageresult := site.image_get(name_lower,structure) or {return error(err)}
		return imageresult
	}else{
		mut res := []ImageActor
		for key in structure.sites.keys(){
			mut site := structure.sites[key]
			imageresult := site.image_get(name_lower,structure) or {continue}
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


pub fn (mut structure PublTools) process() {
	for sitename in structure.sites.keys(){
		mut site := structure.sites[sitename]

		for key in site.pages.keys(){
			mut page := site.pages[key]
			//not mutable
			mut pageactor := PageActor{page:&page, site:&site, publtools:&structure}
			pageactor.process()
		}	
		for key in site.images.keys(){
			mut image := site.images[key]
			mut imageactor := ImageActor{image:&image, site:&site, publtools:&structure}
			imageactor.process()
		}		

		
	}	
}


pub fn (mut site Site) process(publtools PublTools) {
}

pub fn (site Site) path_get(path string) string{	
	return os.join_path(site.path,path)
}

//return fullpath,pageobject
pub fn (site Site) page_get(name string, publtools PublTools) ?PageActor{	
	namelower := name_fix(name)
	if namelower in site.pages {
		mut page2 := site.pages[namelower]
		return PageActor{page:&page2, publtools:&publtools, site:&site}
	}
	return error("Could not find page $namelower in site ${site.name}")
}

//return fullpath,imageobject
pub fn (site Site) image_get(name string, publtools PublTools) ?ImageActor{	
	namelower := name_fix(name)
	if namelower in site.images {
		mut image2 := site.images[namelower]
		return ImageActor{image:&image2, publtools:&publtools, site:&site}
	}
	return error("Could not find image $namelower in site ${site.name}")
}