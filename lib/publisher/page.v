module publishermod

import os
import texttools

pub fn (page Page) write(mut publisher Publisher, content string) {
	os.write_file(page.path_get(mut publisher), content) or { panic('cannot write, $err') }
}

// will load the content, check everything, return true if ok
pub fn (mut page Page) check(mut publisher Publisher) bool {
	page.process(mut publisher) or { panic(err) }

	if page.state == PageStatus.error {
		return false
	}
	return true
}

fn (mut page Page) error_add(error PageError, mut publisher Publisher) {
	if page.state != PageStatus.error {
		// only add when not in error mode yet, because means check was already done
		// println(' - ERROR: $error.msg')
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
pub fn (mut page Page) process(mut publisher Publisher) ?bool {
	if page.state == PageStatus.ok {
		// means was already processed, content is available
		return false
	}

	path_source := page.path_get(mut publisher)
	page.content = os.read_file(path_source) or {
		return error('Failed to open $path_source\nerror:$err')
	}

	page.process_lines(mut publisher) ? // first find all the links
	page.process_includes(mut publisher) ? // should be recursive now

	// if page.state == PageStatus.reprocess{
	// 	page.process(mut publisher) or {return error(err)}
	// }

	// make sure we only execute this once !
	page.state = PageStatus.ok

	return true
}

struct LineProcessorState{
mut:
	nr int
	lines_source []string // needs to be written to the file where we loaded from, is returned as string
	lines_server []string // the return of the process, will go back to page.content
	site &Site
	publisher &Publisher
	page &Page
	links_parser_result ParseResult

}

fn (mut self LineProcessorState) error(msg string){

	page_error := PageError{
		line: self.line
		linenr: self.nr
		msg: msg
		cat: PageErrorCat.brokeninclude
	}
	self.page.error_add(page_error, mut self.publisher)	
	self.lines_source << '> **ERROR: $page_error.msg **<BR>\n\n'
	self.lines_server << '> **ERROR: $page_error.msg **<BR>\n\n'

}

// walk over each line in the page and do the link parsing on it
// will also look for definitions
// happens line per line
fn (mut page Page) process_lines(mut publisher Publisher) ? {

	mut state := LineProcessorState{}

	// first we need to do the links, then the process_includes

	state.site = &publisher.sites[page.site_id]
	state.publisher = publisher

	if site.error_ignore_check(page.name) {
		return
	}

	for line in page.content.split_into_lines() {
		// println ("LINK: $line")

		//the default has been done, which means the source & server have the last line
		//now its up to the future to replace that last line or not
		state.lines_source << line
		state.lines_server << line

		state.nr++


		linestrip := line.strip(" ")

		if linestrip.trim(' ').starts_with('> **ERROR') {
			// these are error messages which will be rewritten if errors are still there
			continue
		}

		if linestrip.starts_with('!!!def') {
			if ':' in line {
				splitted := line.split(':')
				if splitted.len == 2 {					
					for defname in splitted[1].split(',') {
						defname2 := name_fix_no_underscore(defname)
						if defname2 in publisher.defs {
							// println(publisher.defs[defname2])
							page_def_double_id := publisher.defs[defname2]
							page_def_double := publisher.page_get_by_id(page_def_double_id) ?
							{
								panic('cannot find page by id')
							}
							state.error('duplicate definition: $defname, already exists in $page_def_double.name')
						} else {
							publisher.defs[defname2] = page.id
						}
					}					
				} else {
					state.error( 'syntax error in def macro: $line' )
				}
			}else{
				state.error( 'syntax error in def macro (no ":"): $line' )
			}
			continue
		}

		if linestrip.starts_with('!!!include') {
			mut page_name_include := linestrip['!!!include'.len + 1..]
			// println('-includes-- $page_name_include')

			page_name_include2 := publisher.name_fix(page_name_include,site.id) or { 
				println(err)
				panic("aaaa")
				if err.contains("Could not find page"){					
					state.error("Cannot include '$page_name_include'\n$err")
					continue
				}else{
					panic(err)
				}
			}

			if page_name_include2!=page_name_include{
				//means we need to change
				linelast := state.lines_server.pop()
				state.lines_server << linelast.replace(page_name_include,page_name_include2)
			}

			mut page_linked := publisher.page_get(page_name_include2) or {
				//should not happen because page was already found in the name_fix
				panic(err)
			}
			if page_linked.path_get(mut publisher) == page.path_get(mut publisher) {
				state.error('recursive include: ${page_linked.path_get(mut publisher)}')
				continue
			}
			//TODO: does this work? was a reference returned?
			page_linked.nrtimes_inluded++

			// make sure the page we include has been processed
			page_linked.process(mut publisher) or {
				state.error('cannot process page: ${page.name}.\n$err\n')
				continue
			}
			for line_include in page_linked.content.split("\n"){
				state.lines_server << line_include
			}			
			continue
		} 

		//DEAL WITH LINKS
		links_parser_result = link_parser(line)

		// there can be more than 1 link on 1 line
		for mut link in links_parser_result.links {
			link.init()
			link.check(mut publisher, mut page, nr, line)

			if link.state == LinkState.ok {
				if link.original_get() != link.source_get(site.name) {
					source_changed = true
					sourceline = sourceline.replace(link.original_get(), link.source_get(site.name))
					// println(' - REPLACE: $link.original_get() -> ${link.source_get(site.name)}')
				}
			}
			serverline = serverline.replace(link.original_get(), link.server_get())
		} // end of the walk over all links


	} // end of the line walk

	page.content = lines_server // we need to remember what the server needs to give

	if source_changed {
		page.write(mut publisher, lines_source)
		// println(lines_source)
	}
}


		

			lines += line + '\n'
		}
	}
	page.content = lines
	return page.content
}

fn (mut page Page) title() string {
	for line in page.content.split('\n') {
		mut line2 := line.trim(' ')
		if line2.starts_with('#') {
			line2 = line2.trim('#').trim(' ')
			return line2
		}
	}
	return 'NO TITLE'
}

// return a page where all definitions are replaced with link
fn (mut page Page) content_defs_replaced(mut publisher Publisher) ?string {
	site := page.site_get(mut publisher) ?

	tr := texttools.tokenize(page.content)
	mut text2 := page.content
	for def, pageid in publisher.defs {
		page_def := publisher.page_get_by_id(pageid) or { panic(err) }
		// don't replace on your own page
		if page_def.name != page.name {
			for item in tr.items {
				if item.matchstring == def {
					replacewith := '[$item.toreplace](page__${site.name}__$page_def.name)'
					text2 = text2.replace(item.toreplace, replacewith)
				}
			}
		}
	}

	return text2
}
