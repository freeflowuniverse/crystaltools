module publisher

import os

pub fn (page Page) path_get(mut publisher &Publisher) string {
	site_path := publisher.sites[page.site_id].path
	return os.join_path(site_path, page.path)
}

// will load the content, check everything, return true if ok
pub fn (mut page Page) check(mut publisher &Publisher) bool {
	_ := page.markdown_get(mut publisher)
	if page.state == PageStatus.error {
		return false
	}
	return true
}

fn (mut page Page) error_add(error PageError,mut publisher &Publisher) {
	if page.state != PageStatus.error {
		// only add when not in error mode yet, because means check was already done
		page.errors << error
	} else {
		panic(' ** ERROR (2nd time): in file ${page.path_get(mut publisher)}')
	}
}

////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

// process the markdown content and include other files, find links, ...
// find errors
pub fn (mut page Page) process(mut publisher &Publisher) ? {
	if page.status == PageStatus.ok {
		// means was already processed, content is available
		return
	}

	path_source := page.path_get(mut publisher)
	page.content := os.read_file(path_source) or {
		return error('Failed to open $path_source\nerror:$err')
	}

	page.process_links(mut publisher)	//first find all the links
	page.process_includes(mut publisher) // should be recursive now

	return
}



//walk over each line in the page
fn ( page Page) process_links(linkparseresult &ParseResult, publisher &Publisher) ?string {	

	mut lines := ''   //the return of the process, will go back to page.content
	mut nr := 0
	mut lines_source := ""  //needs to be written to the file where we loaded from, is returned as string

	//first we need to do the links, then the process_includes

	site := &publisher.sites[page.site_id]
	
	for line in page.content.split_into_lines() {
		// println (line)
		nr++

		mut links_parser_result := link_parser(line)

		//there can be more than 1 link on 1 line
		for mut link in links_parser_result.links {



			if link.state == LinkState.notfound {
				mut cat := PageErrorCat.brokenlink
				if link.cat == LinkType.image {
					cat = PageErrorCat.brokenimage
				}
				page_error := PageError{
					line: ''
					linenr: 0
					msg: link.error_msg_get()
					cat: cat
				}
				page.error_add(page_error,mut publisher)
			}





	mut sourcelink := "" //the result for how it should be in the source file
	mut serverlink := "" //result of how it needs to be on the server

	mut site := publisher.sites[page.site_id]

	link_description := link.name.trim(" ")
	sitename := site.name

	//only when local we need to check if we can find files/pages or not
	if !link.isexternal && link.cat != LinkType.unknown{

		//parse the different variations of how we can mention a link
		// supported:
		//  site:name
		//  page__sitename__itemname
		//  file__sitename__itemname
		sitename2,itemname := site_page_names_get(link.link)
		if sitename2 != "" {
			//means was specified in the link
			//if not returned means its the site name from the site we are on
			sitename = sitename2
		}

		//we only need the last name for local content
		//can be for image, file & page
		itemname = os.file_name(itemname)

		if link.cat == LinkType.page{
			if !publisher.page_exists(link.link)) {
				return error( "- ERROR: CANNOT FIND LINK: '${link.link}' for $link_description")
			}

			if ! linkclean.contains("__"){
					serverlink = 'page__${sitename}__${itemname}'
			}

		} else {
			// println("found image link:$linkstr")
			
			if !publisher.image_exists(link.link)) {
				return error("- ERROR: CANNOT FIND FILE: '${link.link}' for $link_description")
			}else{
				//remember that the image has been used
				_, mut img := publisher.image_get(link.link) or {panic("bug")}
				if !(page.name in img.usedby){
					img.usedby<<page.name
				}
			}

			if ! linkclean.contains("__"){
					serverlink = 'file__${sitename}__${itemname}'
			}

		}

	}
}



fn (mut page Page) process_includes(mut publisher &Publisher) string {
	
	mut lines := ''   //the return of the process
	mut nr := 0

	// site := &publisher.sites[page.site_id]
	for line in page.content.split_into_lines() {
		// println (line)
		nr++

		mut linestrip := line.trim(' ')
		if linestrip.starts_with('!!!include') {
			name := linestrip['!!!include'.len + 1..]
			// println('-includes-- $name')
			mut _, mut page_linked := publisher.page_get(name) or {
				// println("-includes-- could not get page $name")
				page_error := PageError{
					line: line
					linenr: nr
					msg: "Cannot inlude '$name'\n$err"
					cat: PageErrorCat.brokeninclude
				}
				page.error_add(page_error, mut publisher)
				lines += '> ERROR: $page_error.msg'
				continue
			}
			if page_linked.path_get(mut publisher) == page.path_get(mut publisher) {
				panic('recursive include: ${page_linked.path_get(mut publisher)}')
			}
			page_linked.nrtimes_inluded++
			// path11 := page_linked
			content_linked := page_linked.markdown_get(mut publisher)
			lines += content_linked + '\n'
		} else {
			lines += line + '\n'
		}
	}
	return lines
}

