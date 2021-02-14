module publisher

import os


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

// walk over each line in the page and do the link parsing on it
// will also look for definitions
// happens line per line
fn (mut page Page) process_lines(mut publisher Publisher) ? {
	mut nr := 0
	mut lines_source := '' // needs to be written to the file where we loaded from, is returned as string
	mut lines_server := '' // the return of the process, will go back to page.content
	mut sourceline := '' // what we will replace with on source
	mut serverline := ''

	mut source_changed := false // if we need to rewrite the source

	// first we need to do the links, then the process_includes

	mut site := &publisher.sites[page.site_id]

	if site.error_ignore_check(page.name) {
		return
	}

	mut links_parser_result := ParseResult{}

	for line in page.content.split_into_lines() {
		// println ("LINK: $line")

		if line.trim(' ').starts_with('> **ERROR') {
			// these are error messages which will be rewritten if errors are still there
			continue
		}

		nr++

		sourceline = line // what we will replace with on source
		serverline = line

		if line.trim(' ').starts_with("!!!def"){
			if ":" in line{
				splitted := line.split(":")
				if splitted.len == 2{
					for defname in splitted[1].split(","){
						defname2 := name_fix_no_underscore(defname)
						if defname2 in publisher.defs{
							// println(publisher.defs[defname2])
							pageid_double := publisher.defs[defname2]
							otherpage := publisher.page_get_by_id(pageid_double)? {panic("cannot find page by id")}
							page.error_add({line:line,linenr:nr,msg:"duplicate definition: $defname, already exists in $otherpage.name"}, mut publisher)
						} else {
							publisher.defs[defname2] = page.id
							continue
						}
					}
				}else{
					page.error_add({line:line,linenr:nr,msg:"syntax error in def macro"}, mut publisher)						
				}
			}
			continue
		}

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

		lines_source += sourceline + '\n'
		lines_server += serverline + '\n'

		// //now we need to check if there were errors if yes lets put them in the source code
		// //this will make it easy to spot errors and fix, remember endusers will see it too
		// for err in errors{
		// 	lines_server += "> **ERROR: $err**<br>\n\n"
		// }
	} // end of the line walk

	page.content = lines_server // we need to remember what the server needs to give

	if source_changed {
		page.write(mut publisher, lines_source)
		// println(lines_source)
	}
}

fn (mut page Page) replace_write(mut publisher Publisher, tofind string, toreplace string) ? {
	path_source := page.path_get(mut publisher)
	mut content := os.read_file(path_source) or {
		return error('Failed to open $path_source\nerror:$err')
	}

	content = content.replace(tofind, toreplace)

	os.write_file(path_source, content) or {
		return error('Failed to write $path_source\nerror:$err')
	}

	page.state = PageStatus.reprocess // makes sure that page will be re-processed
}

fn (mut page Page) process_includes(mut publisher Publisher) ?string {
	mut lines := '' // the return of the process
	mut nr := 0
	mut linestrip_fix := ''
	mut site := publisher.site_get_by_id(page.site_id) ?

	// site := &publisher.sites[page.site_id]
	for line in page.content.split_into_lines() {
		// println (line)
		nr++

		mut linestrip := line.trim(' ')
		if linestrip.starts_with('!!!include') {
			mut name := linestrip['!!!include'.len + 1..]
			// println('-includes-- $name')
			if site.name_change_check(name) {
				// the name of the include changed, will remove .md and will get the alias
				linestrip_fix = linestrip.replace(name, site.name_fix_alias(name))
				name = site.name_fix_alias(name)
				page.replace_write(mut publisher, linestrip, linestrip_fix) or { return error(err) }
			}
			mut page_linked := publisher.page_get(name) or {
				// println("-includes-- could not get page $name")
				page_error := PageError{
					line: line
					linenr: nr
					msg: "Cannot inlude '$name'\n$err"
					cat: PageErrorCat.brokeninclude
				}

				page.error_add(page_error, mut publisher)

				lines += '> **ERROR: $page_error.msg **<BR>\n\n'
				continue
			}
			if page_linked.path_get(mut publisher) == page.path_get(mut publisher) {
				panic('recursive include: ${page_linked.path_get(mut publisher)}')
			}
			page_linked.nrtimes_inluded++

			// make sure the page we include has been processed
			page_linked.process(mut publisher) or {
				return error('cannot process page: ${page.name}.\n$err\n')
			}
			lines += '$page_linked.content\n'
		} else {
			lines += line + '\n'
		}
	}
	page.content = lines
	return page.content
}


fn (mut page Page)title() string {
	for line in page.content.split("\n"){
		mut line2 := line.trim(" ")
		if line2.starts_with("#"){
			line2 = line2.trim("#").trim(" ")
			return line2
		}
	}
	return "NO TITLE"
}