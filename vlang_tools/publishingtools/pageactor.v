module publishingtools

import os

//nothing kept in mem, just to process one iteration
struct PageActor {
	page &Page
	site &Site
	publtools &PublTools
}


pub fn (mut pageactor PageActor) path_get() string{
	return os.join_path(pageactor.site.path,pageactor.page.path)
}

//process the markdown content and include other files, find links, ...
pub fn (mut pageactor PageActor) process(){
	mut content := pageactor.content_get() or {panic(err)}
	content = pageactor.process_content(content)
}

pub fn (mut pageactor PageActor) content_get() ?string{
	path := pageactor.path_get()
	content := os.read_file(pageactor.path_get()) or {
		println('Failed to open ${pageactor.path_get()}')
		println(pageactor)
		return err
	}	
	return content
}



fn (mut pageactor PageActor) process_content(content string) string{	
	mut lines:=[]string
	mut nr:=0
	for line in content.split_into_lines() {
			// println (line)
			nr++
			mut linestrip := line.trim(" ")
			if linestrip.starts_with("!!!include"){
				mut name := linestrip["!!!include".len+1..]
				name = name.replace("::",":")
				name = name.replace(";",":")
				mut ss := pageactor.publtools
				mut pageobj_linked := ss.page_get(name) or { 
					// errormsg := "Cannot inlude '$name' on page: ${pageactor.path_get()}"
					// println(errormsg)
					// page_error := PageError{line:line, linenr:nr, error:errormsg}
					// pageobj_linked.errors << page_error
					continue
					}
				// pageobj_linked.page.nrtimes_inluded ++
				// content_linked := pageobj_linked.content_get() or {return}
				println(pageobj_linked)
			}	
		return ""
	}
	return ""

}
