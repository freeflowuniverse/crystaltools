module publishermod

import os
import texttools

pub fn (page Page) write(mut publisher Publisher, content string) {
	mut path := page.path_get(mut publisher)
	if path.ends_with('.md') {
		path = path[..path.len - 3]
	}
	path += '.md'
	os.write_file(path, content) or { panic('cannot write, $err') }
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
pub fn (mut page Page) load(mut publisher Publisher) ?bool {
	if page.state == PageStatus.ok {
		// means was already processed, content is available
		return false
	}

	path_source := page.path_get(mut publisher)
	page.content = os.read_file(path_source) or {
		return error('Failed to open $path_source\nerror:$err')
	}

	// loads the defs
	page.process_lines(mut publisher, true) ?

	return true
}

pub fn (mut page Page) process(mut publisher Publisher) ?bool {
	if page.state == PageStatus.ok {
		// means was already processed, content is available
		return false
	}

	page.process_lines(mut publisher, false) ? // first find all the links
	// println(page.content)
	// make sure we only execute this once !
	page.state = PageStatus.ok

	return true
}

struct LineProcessorState {
mut:
	nr             int
	lines_source   []string // needs to be written to the file where we loaded from, is returned as string
	lines_server   []string // the return of the process, will go back to page.content
	site           &Site
	publisher      &Publisher
	page           &Page
	changed_source bool
	changed_server bool
}

fn (mut state LineProcessorState) error(msg string) {
	page_error := PageError{
		line: state.lines_source[state.lines_source.len - 1]
		linenr: state.nr
		msg: msg
		cat: PageErrorCat.brokeninclude
	}
	state.page.error_add(page_error, mut state.publisher)
	// state.lines_source << '> **ERROR: $page_error.msg **<BR>\n\n'
	if !(state.page.name in ["sidebar","navbar"]){
		state.lines_server << '> **ERROR: $page_error.msg **<BR>\n\n'
		// println(' > Error: $state.page.name: $msg')
	}
}

fn (mut state LineProcessorState) serverline_change(ffrom string, tto string) {
	linelast := state.lines_server.pop()
	state.lines_server << linelast.replace(ffrom, tto)
	state.changed_server = true
}

fn (mut state LineProcessorState) sourceline_change(ffrom string, tto string) {
	linelast := state.lines_source.pop()
	state.lines_source << linelast.replace(ffrom, tto)
	state.changed_source = true
}

// walk over each line in the page and do the link parsing on it
// will also look for definitions
// happens line per line
fn (mut page Page) process_lines(mut publisher Publisher, dodefs bool) ? {
	mut state := LineProcessorState{
		site: &publisher.sites[page.site_id]
		publisher: publisher
		page: page
	}

	// first we need to do the links, then the process_includes

	state.site = &publisher.sites[page.site_id]
	state.publisher = publisher

	if state.site.error_ignore_check(page.name) {
		return
	}

	for line in page.content.split_into_lines() {
		// println ("LINK: $line")

		// the default has been done, which means the source & server have the last line
		// now its up to the future to replace that last line or not
		state.lines_source << line
		state.lines_server << line

		state.nr++

		linestrip := line.trim(' ')

		if linestrip.trim(' ').starts_with('> **ERROR') {
			// these are error messages which will be rewritten if errors are still there
			continue
		}

		if dodefs {
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
						state.error('syntax error in def macro: $line')
					}
				} else {
					state.error('syntax error in def macro (no ":"): $line')
				}
				continue
			}
			continue
		}

		if linestrip.starts_with('!!!include') {
			mut page_name_include := linestrip['!!!include'.len + 1..]
			// println('-includes-- $page_name_include')


			page_name_include2 := publisher.name_fix_check_page(page_name_include, state.site.id) or {
				e1 := '$err'.contains('Could not find')
				if e1 {
					state.error('include, cannot find page: $page_name_include')
				} else {
					state.error('include, cannot find page: $page_name_include\n$err')
				}
				continue
			}
			if page_name_include2 != page_name_include {
				// means we need to change
				state.serverline_change(page_name_include, page_name_include2)
			}

			mut page_linked := publisher.page_get(page_name_include2) or {
				// should not happen because page was already found in the name_fix
				state.error('$page_name_include2: $err')
				continue
			}
			if page_linked.path_get(mut publisher) == page.path_get(mut publisher) {
				state.error('recursive include: ${page_linked.path_get(mut publisher)}')
				continue
			}
			// TODO: does this work? was a reference returned?
			page_linked.nrtimes_inluded++

			// make sure the page we include has been processed
			page_linked.process(mut publisher) or {
				state.error('cannot process page: ${page.name}.\n$err\n')
				continue
			}
			for line_include in page_linked.content.split('\n') {
				state.lines_server << line_include
			}
			continue
		}
		// DEAL WITH LINKS
		links_parser_result := link_parser(line)

		// there can be more than 1 link on 1 line
		for mut link in links_parser_result.links {
			link.init()
			link.check(mut publisher, mut page, state.nr, line)

			if link.state != LinkState.ok {
				state.error('link:' + link.error_msg)
				continue
			}

			if link.cat == LinkType.page || link.cat == LinkType.file {
				mut ispage := false
				if link.cat == LinkType.page {
					ispage = true
				}

				name_to_find := link.original_link
				namefound := publisher.name_fix_check(name_to_find, state.site.id, ispage) or {
					e2 := '$err'.contains('Could not find')
					if e2 {
						state.error('cannot find link: $name_to_find')
					} else {
						state.error('cannot find link: $name_to_find\n$err')
					}
					continue
				}
				link.filename = namefound
				if link.state == LinkState.ok {
					if link.original_get() != link.source_get(state.site.name) {
						state.sourceline_change(link.original_get(), link.source_get(state.site.name))
					}
				}
				state.serverline_change(link.original_get(), link.source_get(state.site.name))
			}
		} // end of the walk over all links
	} // end of the line walk

	if dodefs {
		return
	}
	page.content = state.lines_server.join('\n')

	if state.changed_source {
		page.write(mut publisher, state.lines_source.join('\n'))
		// println(lines_source)
	}
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
