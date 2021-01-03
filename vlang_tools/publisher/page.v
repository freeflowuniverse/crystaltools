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


// will replace the links to be correct (see if they exist in the known sites, )
pub fn (mut page Page) check_links(lines string, mut link Link, mut publisher &Publisher) string {
	site := &publisher.sites[page.site_id]
	if link.state == LinkState.external {
		// no need to process are external links
		return lines
	}
	// if not empty, we have already processed this so can return right away
	if link.dest != '' {
		return lines
	}
	mut lines_out := ''
	mut new_text := ''
	mut original_text := '[$link.name]($link.link)'
	mut linkstr := link.link
	// support for links like ./img/zero_db.png, needs to become $site:zero_db.png
	linkstr = os.file_name(linkstr)

	if ! linkstr.contains("__"){
		if link.cat == LinkType.link {
			linkstr = 'page__${site.name}__$linkstr'
		}else{
			//works for image and other files
			linkstr = 'file__${site.name}__$linkstr'
		}
	}

	// mut new_link := ""
	// if originSite == site.name{
	// 	new_link = linkstr.split(":")[1]
	// }else{
	// 	splitted := linkstr.split(":")
	// 	sitename := splitted[0]
	// 	item := splitted[1]
	// 	new_link = "/$sitename/$item"
	// 	if link.cat == LinkType.image{
	// 		domain := pt.domain
	// 		new_link = "$domain$new_link"
	// 	}
	// }
	new_text = ''
	new_link := linkstr // need to check if ok TODO:
	if link.state == LinkState.init {
		// need to check if link exists
		if link.cat == LinkType.link {
			if !publisher.page_exists(linkstr) {
				link.state = LinkState.notfound
				new_text = "- ERROR: CANNOT FIND LINK: '$linkstr' for ${link.name.trim()}"
			}

		} else {
			// println("found image link:$linkstr")
			if !publisher.image_exists(linkstr) {
				link.state = LinkState.notfound
				new_text = "- ERROR: CANNOT FIND IMAGE: '$linkstr' for ${link.name.trim()}"
			}else{
				_, mut img := publisher.image_get(linkstr) or {panic("bug")}
				if !(page.name in img.usedby){
					img.usedby<<page.name
				}
			}
		}
		link.state = LinkState.ok
	}
	new_text = '[${link.name.trim(' ')}]($new_link)'
	if link.cat == LinkType.image {
		// add the ! to be a link
		new_text = '!$new_text'
		original_text = '!$original_text'
	}
	lines_out = lines.replace(original_text, new_text)
	link.dest = new_link // so now we know the proper destination string, TODO: check it does not happen multiple times
	return lines_out
}