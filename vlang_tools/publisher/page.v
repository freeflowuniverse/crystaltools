module publisher

import os

pub fn (page Page) path_get(mut publisher &Publisher) string {
	site_path := publisher.sites[page.site_id].path
	return os.join_path(site_path, page.path)
}

// will load the content, check everything, return true if ok
pub fn (mut page Page) check(mut publisher &Publisher) bool {
	page.process(mut publisher)

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
// if it returns false, it means was already processed
pub fn (mut page Page) process(mut publisher &Publisher) ?bool {
	if page.state == PageStatus.ok {
		// means was already processed, content is available
		return false
	}

	path_source := page.path_get(mut publisher)
	page.content = os.read_file(path_source) or {
		return error('Failed to open $path_source\nerror:$err')
	}

	page.process_links(mut publisher)	//first find all the links
	page.process_includes(mut publisher) // should be recursive now

	//make sure we only execute this once !
	page.state = PageStatus.ok

	return true
}



//walk over each line in the page and do the link parsing on it
//happens line per line
fn ( mut page Page) process_links(mut publisher &Publisher) ?string {	

	mut nr := 0
	mut lines_source := ""  //needs to be written to the file where we loaded from, is returned as string
	mut lines_server := ''   //the return of the process, will go back to page.content

	mut sourcelink := "" //what we will replace with on source
	mut serverlink := ""
	mut link_link := ""

	mut sourceline := "" //what we will replace with on source
	mut serverline := ""

	mut link_description:= ""

	//first we need to do the links, then the process_includes

	mut site := &publisher.sites[page.site_id]
	mut sitename := site.name

	mut links_parser_result := ParseResult{}

	mut errors := []string{}

	for line in page.content.split_into_lines() {
		// println (line)

		if line.trim(" ").starts_with("> **ERROR"){
			//these are error messages which will be rewritten if errors are still there
			continue
		}

		nr++
		
		sourceline = line //what we will replace with on source
		serverline = line		
		links_parser_result = link_parser(line)
		//there can be more than 1 link on 1 line
		for mut link in links_parser_result.links {

			sourcelink = "" //the result for how it should be in the source file
			serverlink = "" //result of how it needs to be on the server

			link_description = link.name.trim(" ")

			//only when local we need to check if we can find files/pages or not
			if !link.isexternal && link.cat != LinkType.unknown{

				//parse the different variations of how we can mention a link
				// supported:
				//  site:name
				//  page__sitename__itemname
				//  file__sitename__itemname
				mut sitename2, mut itemname := site_page_names_get(link.link) or {return err}
				if sitename2 != "" {
					//means was specified in the link
					//if not returned means its the site name from the site we are on
					sitename = sitename2
				}

				//we only need the last name for local content
				//can be for file, file & page
				itemname = os.file_name(itemname)

				if link.cat == LinkType.page{
					serverlink = '[${link_description}](page__${sitename}__${itemname}.md)'
					if ! publisher.page_exists("$sitename:$itemname") {
						errormsg :=  "ERROR: CANNOT FIND LINK: '${link.link}' for $link_description"
						errors << errormsg
						page.error_add({
							line:   line
							linenr: nr
							msg: errormsg  
							cat:    PageErrorCat.brokenlink
						}, mut publisher)
					}
				} else {
					serverlink = '[${link_description}](file__${sitename}__${itemname})'
					if _ := publisher.file_exists("$sitename:$itemname") {
						//remember that the file has been used
						mut file := publisher.file_get("$sitename:$itemname") or {
							return err
						}
						if !(page.site_id in file.usedby){
							file.usedby<<page.id
						}

					}else{
						errormsg :=  "ERROR: CANNOT FIND FILE: '${link.link}' for $link_description"
						errors << errormsg
						page.error_add({
							line:   line
							linenr: nr
							msg:    errormsg
							cat:    PageErrorCat.brokenlink
						}, mut publisher)
					}					
				}

				//now we need to cleanup the source
				if site.name == sitename{
					link_link = itemname
				} else{
					link_link = "$sitename:$itemname"
				}
				
			}else{
				//was no page or file on the localserver
				//we can only do some generic cleanup now
				link_link = link.link.trim(" ")
			}

			//lets cleanup the sourcecode & the code which will come from server

			sourcelink = "[${link_description}](${link_link})"
			
			if serverlink == ""{
				serverlink = sourcelink
			}

			if link.isfile{
				sourcelink = "!${sourcelink}"
				serverlink = "!${serverlink}"
			}			

			sourceline=sourceline.replace(link.link_original_get(),sourcelink)
			serverline=serverline.replace(link.link_original_get(),serverlink)

		}//end of the walk over all links

		lines_source += sourceline + "\n"
		lines_server += serverline + "\n"

		//now we need to check if there were errors if yes lets put them in the source code
		//this will make it easy to spot errors and fix, remember endusers will see it too
		// for err in errors{
		// 	lines_source += "> **ERROR: $err**<br>\n\n"
		// 	lines_server += "> **ERROR: $err**<br>\n\n"
		// }

	}//end of the line walk

	page.content = lines_server //we need to remember what the server needs to give
	//we return the source lines, so we can choose to store it on fs or not
	return lines_source

}



fn (mut page Page) process_includes(mut publisher &Publisher) ?string {
	
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
			mut page_linked := publisher.page_get(name) or {
				// println("-includes-- could not get page $name")
				page_error := PageError{
					line: line
					linenr: nr
					msg: "Cannot inlude '$name'\n$err"
					cat: PageErrorCat.brokeninclude
				}
				
				page.error_add(page_error, mut publisher)
				
				lines += '> **ERROR: ${page_error.msg} **<BR>\n\n'
				continue
			}
			if page_linked.path_get(mut publisher) == page.path_get(mut publisher) {
				panic('recursive include: ${page_linked.path_get(mut publisher)}')
			}
			page_linked.nrtimes_inluded++

			//make sure the page we include has been processed
			page_linked.process(mut publisher) or {return error("cannot process page: ${page.name}.\n$err\n")}
			lines += "$page_linked.content\n"
		} else {
			lines += line + '\n'
		}
	}
	page.content = lines
}

