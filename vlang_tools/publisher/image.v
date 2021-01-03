module publisher

import os

pub fn (image Image) path_get(mut publisher &Publisher) string {
	if image.site_id>publisher.sites.len{
		panic("cannot find site: ${image.site_id}, not enough elements in list.")
	}	
	site_path := publisher.sites[image.site_id].path
	return os.join_path(site_path, image.path)
}

// need to create smaller sizes if needed and change the name
//also need to make sure its in right directory
pub fn (mut image Image) process(mut publisher &Publisher) {
	// println(image)
	// if image.site_id>publisher.sites.len{
	// 	panic("cannot find site: ${image.site_id}, not enough elements in list.")
	// }
	// mut site := publisher.sites[image.site_id]
	// mut path := image.path_get(mut publisher)
	// mut dest:= ""
	// if path.contains("presos"){
	// 	println(image)
	// }
	// if image.usedby.len>0{
	// 	// println("${image.name} used")
	// 	if image.usedby.len>1{
	// 		if path.contains("img_multiple_use"){
	// 			//already processed
	// 			return
	// 		}		
	// 		//means more than 1 page use this image
	// 		dest = "${site.path}/img_multiple_use/${os.base(path)}"
	// 		if os.exists(dest){
	// 			os.rm(path)
	// 		}else{
	// 			os.mv(path,dest)
	// 		}			
	// 	}else{
	// 		pagename_who_has_image := image.usedby[0]
	// 		_, mut page_image := publisher.page_get(pagename_who_has_image) or {panic(err)}
	// 		page_path := page_image.path_get(mut publisher)
	// 		dest = os.dir(page_path)+"/img/${os.base(path)}"
	// 		if dest.replace("//","/").trim(" /")==path.replace("//","/").trim(" /"){return}			
	// 		if os.exists(dest){
	// 			// panic("double file: fix first: $path -> $dest")
	// 			os.rm(path)
	// 		}else{
	// 			os.mv(path,dest)
	// 		}		
	// 	}
	// }else{
	// 	if path.contains("img_notused"){
	// 		return
	// 	}
	// 	println("${image.name} not used")
	// 	dest = "${site.path}/img_notused/${os.base(path)}"
	// 	if os.exists(dest){
	// 		panic("double file: fix first: $path -> $dest")
	// 	}else{
	// 		os.mv(path,dest)
	// 	}
	// }
}
