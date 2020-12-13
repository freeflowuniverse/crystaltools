module finder

import os
// import json


struct SiteStructure {
	pub mut:
		sites map[string]Site
}


pub fn (mut structure SiteStructure) load(name string, path string) {	
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
	println("load finder: $path2")
	structure.sites[name_lower] = Site({path:path2, name:name_lower})
	structure.sites[name_lower].process_files(path2)
}

pub fn get() SiteStructure{
	mut structure := SiteStructure{}
	return structure
}

pub fn (mut structure SiteStructure) site_get(name string) Site{	
	mut name_lower := name_fix(name)
	return structure.sites[name_lower]
}

fn name_fix(name string) string {	
	mut name_lower := name.to_lower()
	if name_lower.ends_with(".md"){
		name_lower = name_lower[0..name_lower.len-3]
	}
	return name_lower
}

//name in form: 'sitename:pagename' or 'pagename'
pub fn (mut structure SiteStructure) page_get(name string) ?Page {	
	mut name_lower := name_fix(name)
	if ":" in name_lower {
		splitted := name_lower.split(":")
		if splitted.len !=1 {
			panic("name needs to be in format 'sitename:pagename' or 'pagename', now '$name_lower'")
		}
		sitename := splitted[0]
		mut site := structure.site_get(sitename)
		page := site.page_get(name_lower) or {return error(err)}
		return page
	}else{

		for key in structure.sites.keys(){
			mut site := structure.sites[key]
			page :=  site.page_get(name_lower) or {continue}
			return page
		}

		return error ("Could not find page: '$name'")
	}	

}

// pub fn (mut structure SiteStructure) image_get(name string) Image{	
// 	site := structure.site_get(sitename)
// 	return site.image_get(name)
// }

pub fn (mut structure SiteStructure) process() {
	for sitename in structure.sites.keys(){
		structure.sites[sitename].process()
	}	
}