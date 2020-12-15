module publishingtools

import os

//nothing kept in mem, just to process one iteration
struct PageActor {
	pub mut:
		page Page
		site Site
		publtools PublTools
}

//return fullpath,pageobject
pub fn (site Site) pageactor_get(name string, publtools PublTools) ?PageActor{	
	namelower := name_fix(name)
	if namelower in site.pages {
		page := &site.pages[namelower]
		return PageActor{page:page, publtools:&publtools, site:&site}
	}
	return error("Could not find page $namelower in site ${site.name}")
}


pub fn (pageactor PageActor) path_get() string{
	return os.join_path(pageactor.site.path,pageactor.page.path)
}

//process the markdown content and include other files, find links, ...
pub fn (mut pageactor PageActor) process(){
	content := pageactor.content_get() or {panic(err)}
	content2 := pageactor.process_content(content)
}

pub fn (pageactor PageActor) content_get() ?string{
	path_source2 := pageactor.path_get()
	content := os.read_file(pageactor.path_get()) or {
		path_source := pageactor.path_get()
		println('Failed to open ${path_source}')
		return err
	}	
	return content
}



fn (mut pageactor PageActor) process_content(content string) string{	
	// mut lines:=[]string{}
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
				mut pageactor_linked := ss.page_get(name) or { 
					path_source := pageactor.path_get()
					errormsg := "Cannot inlude '$name' on page: $path_source"
					println(errormsg)
					page_error := PageError{line:line, linenr:nr, error:errormsg}
					pageactor.page.errors << page_error
					continue
					}
				if pageactor_linked.path_get() == pageactor.path_get() {
					panic("recursive include: $pageactor_linked.path_get()")
				}	
				pageactor_linked.page.nrtimes_inluded ++
				path11 := pageactor_linked.page
				content_linked := pageactor_linked.content_get() or {return err}
			}	
		return ""
	}
	return ""

}
