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

// process the markdown content and include other files, find links, ...
// the content is the processed
// originSite is the site that wants to include a markdown page
pub fn (mut page Page) markdown_get(mut publisher &Publisher) string {
	if page.content != '' {
		// means was already processed, content is available
		return page.content
	}
	mut content := page.markdown_load(mut publisher) or { panic(err) }
	content = page.process_includes(content,mut publisher) // should be recursive now
	// check for links
	mut links_parser_result := link_parser(content)
	for mut link in links_parser_result.links {
		content = page.check_links(content, mut link, mut publisher)
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
	}
	page.content = content
	return page.content
}

pub fn (page Page) markdown_load(mut publisher &Publisher) ?string {
	path_source := page.path_get(mut publisher)
	content := os.read_file(path_source) or {
		return error('Failed to open $path_source\nerror:$err')
	}
	return content
}

pub fn (mut page Page) error_add(error PageError,mut publisher &Publisher) {
	if page.state != PageStatus.error {
		// only add when not in error mode yet, because means check was already done
		page.errors << error
	} else {
		panic(' ** ERROR (2nd time): in file ${page.path_get(mut publisher)}')
	}
}

fn (mut page Page) process_includes(content string, mut publisher &Publisher) string {
	mut lines := ''
	mut nr := 0
	// site := &publisher.sites[page.site_id]
	for line in content.split_into_lines() {
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
