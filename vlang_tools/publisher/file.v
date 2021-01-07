module publisher

import os

pub fn (file File) path_get(mut publisher &Publisher) string {
	if file.site_id>publisher.sites.len{
		panic("cannot find site: ${file.site_id}, not enough elements in list.")
	}	
	site_path := publisher.sites[file.site_id].path
	return os.join_path(site_path, file.path)
}

// need to create smaller sizes if needed and change the name
//also need to make sure its in right directory
pub fn (mut file File) process(mut publisher &Publisher) {
	if file.site_id>publisher.sites.len{
		panic("cannot find site: ${file.site_id}, not enough elements in list.")
	}
	mut site := publisher.sites[file.site_id]
	mut path := file.path_get(mut publisher)
	mut dest:= ""
	
	if file.usedby.len>0{
		// println("${file.name} used")
		if file.usedby.len>1{
			if path.contains("img_multiple_use"){
				//already processed
				return
			}		
			//means more than 1 page use this file
			dest = "${site.path}/img_multiple_use/${os.base(path)}"
			if os.exists(dest){
				os.rm(path)
			}else{
				os.mv(path,dest)
			}			
		}else{
			pageid_who_has_file := file.usedby[0]
			mut page_file := publisher.page_get_by_id(pageid_who_has_file) or {panic(err)}
			page_path := page_file.path_get(mut publisher)
			dest = os.dir(page_path)+"/img/${os.base(path)}"
			if dest.replace("//","/").trim(" /")==path.replace("//","/").trim(" /"){return}			
			if os.exists(dest){
				// panic("double file: fix first: $path -> $dest")
				os.rm(path)
			}else{
				os.mv(path,dest)
			}		
		}
	}else{
		if path.contains("img_notused"){
			return
		}
		
		println("${file.name} not used")
		dest = "${site.path}/img_notused/${os.base(path)}"
		if !os.exists(dest){
			os.mv(path,dest)
		}
	}
	file.path = dest
}