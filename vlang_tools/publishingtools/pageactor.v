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

//will load the content, check everything, return true if ok
pub fn (mut pageactor PageActor) check() bool{
	content := pageactor.markdown_get()
	if pageactor.page.state == PageStatus.error{
		return false
	}
	return true
}

//process the markdown content and include other files, find links, ...
//the content is the processed 
pub fn (mut pageactor PageActor) markdown_get() string{

	if pageactor.page.content!=""{
		//means was already processed, if fast enough we can leave this away that way we know includes are dynamic
		return pageactor.page.content
	}

	mut content := pageactor.markdown_load() or {panic(err)}
	for i in 0 .. 10 {
		if i>9 {
			panic ("too many level of includes in ${pageactor.path_get()}")
		}
		if i>3{
			panic("s")
		}
		content = pageactor.process_includes(content)
		if !content.contains("!!!include") {
			//means we got all the includes 
			break
		}
	}
	if pageactor.page.errors.len > 0{
		pageactor.page.state = PageStatus.error
	}

	// check for links
	mut res:= link_parser(content)
	// mut link:=Link{}
	for mut link in res.links{
		content = link.check_replace(content, pageactor.publtools, pageactor.site)
		// println("${replaceaction.original_text}->${replaceaction.new_text}")
		if link.state == LinkState.notfound{
			mut cat:=PageErrorCat.brokenlink
			if link.cat == LinkType.image{
				cat=PageErrorCat.brokenimage
			}
			page_error := PageError{line:"", linenr:0, msg:link.error_msg_get(), cat:cat}	
			pageactor.error_add(page_error)		
		}
	}

	pageactor.page.content = content

	return pageactor.page.content
}

pub fn (pageactor PageActor) markdown_load() ?string{
	// path_surce2 := pageactor.path_get()
	content := os.read_file(pageactor.path_get()) or {
		path_source := pageactor.path_get()
		println('Failed to open ${path_source}')
		return err
	}	
	return content
}

pub fn (mut pageactor PageActor) error_add(error PageError){
	if pageactor.page.state != PageStatus.error{
		//only add when not in error mode yet, because means check was already done
		pageactor.page.errors << error
	}
	println(" ** ERROR: in file ${pageactor.path_get()}")
	println(error)

} 


fn (mut pageactor PageActor) process_includes(content string) string {	

	mut lines:=""
	mut nr:=0

	for line in content.split_into_lines() {
		// println (line)
		nr++
		mut linestrip := line.trim(" ")
		if linestrip.starts_with("!!!include"){
			name := linestrip["!!!include".len+1..]
			mut pt := pageactor.publtools
			mut pageactor_linked := pt.page_get(name) or { 
				page_error := PageError{line:line, linenr:nr, msg:"Cannot inlude '$name'\n${err}", 
													cat:PageErrorCat.brokeninclude }
				pageactor.error_add(page_error)
				lines += "> ERROR: ${page_error.msg}"
				continue
				}
			if pageactor_linked.path_get() == pageactor.path_get() {
				panic("recursive include: ${pageactor_linked.path_get()}")
			}	
			pageactor_linked.page.nrtimes_inluded ++
			// path11 := pageactor_linked.page
			content_linked := pageactor_linked.markdown_load() or {return err}
			lines += content_linked+"\n"
		}
		lines += line+"\n"
	}

	return lines

}

