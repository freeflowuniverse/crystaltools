module finder

import os
// import json

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

pub fn (pageresult PageResult) content_get() ?string{
	contents := os.read_file(pageresult.path) or {
		println('Failed to open ${pageresult.path}')
		println(pageresult)
		return err
	}	
	return contents
}


//process the markdown content and include other files, find links, ...
pub fn (mut page Page) process(site Site){
	mut path := os.join_path(site.path,page.path)
	contents := os.read_file(path) or {
		println('Failed to open $path')
		return
	}
	mut lines:=[]string
	for line in contents.split_into_lines() {
			// println (line)
			mut linestrip := line.trim(" ")
			if linestrip.starts_with("!!!include"){
				mut name := linestrip["!!!include".len+1..]
				name = name.replace("::",":")
				name = name.replace(";",":")
				pageresult := site.page_get(name) or { 
					println("Cannot inlude '$name' on page: $path")
					continue
					}
				content := pageresult.content_get() or {return}
				println(content)
			}
		}	

}
