module publishermod

fn (mut publ Publisher) name_fix_alias_name(name string) ?string {
	name0 := publ.replacer.file.replace(name) ?
	return name_fix(name0)
}

fn (mut publ Publisher) name_fix_alias_site(name string) ?string {
	name0 := publ.replacer.site.replace(name) ?
	return name_fix(name0)
}

fn (mut publ Publisher) name_fix_alias_file(name string) ?string {
	name0 := publ.replacer.file.replace(name) ?
	return name_fix(name0)
}

fn (mut publ Publisher) name_fix_alias_word(name string) ?string {
	name0 := publ.replacer.file.replace(name) ?
	return name0.trim(' ')
}



//check the name and fix if needed
pub fn (mut publisher Publisher) name_fix(name string, site_id int) ?string {
	mut name2:=name
	page_dest := publisher.page_get(name) or { 

		sitename, pagename := name_split(name) ?

		sitename_replaced := publisher.replacer.site.replace(sitename) ?
		pagename_replaced := publisher.replacer.file.replace(pagename) ?

		name2 = "$sitename:$pagename"

		if name2!=name{
			println (" - found replace: $name -> $name2")
		}
		
		page_dest2 := if publisher.page_get(name2) or {
			//now we still did not find even after looking for replacement
			//lets look at the definitions
			page_dest3 := publisher.def_page_get(pagename_replaced) or { 
				return error("Could not find page $name not from definitions or page name.\n$err")
			}
			//return to page_dest2
			page_dest3

		}
		//return to page_dest
		page_dest2

	}

	if site_id  != page_dest.site_id {
		pagename2 := page_dest.name
		site2 := publisher.site_get_by_id(site_id)
		sitename2 := site2.name
		return "$sitename2:$pagename2"
	}
	return "${page_dest.name}"

}



pub fn (mut publisher Publisher) file_get_fix(name string, page_source Page) ?&Page {
	println(" >debug: C")
	page_dest := publisher.page_get(name) or { 

		sitename, pagename := name_split(name) ?

		sitename_replaced := publisher.replacer.site.replace(sitename) ?
		if sitename != sitename_replaced {
			page_source.replace_write(mut publisher, '!!!include:$sitename:', '!!!include:$sitename_replaced:') or { return error(err) }
			page_source.replace_write(mut publisher, '($sitename:', '($sitename_replaced:') or { return error(err) }
			page.replace_write(mut publisher, '( $sitename:', '($sitename_replaced:') or { return error(err) }
		}
		pagename_replaced := publisher.replacer.file.replace(pagename) ?
		if pagename != pagename_replaced {
			page_source.replace_write(mut publisher, ':$pagename:', ':$pagename_replaced:') or { return error(err) }
			page_source.replace_write(mut publisher, '($pagename:', '($pagename_replaced:') or { return error(err) }
			page_source.replace_write(mut publisher, '( $pagename:', '($pagename_replaced:') or { return error(err) }
		}
		println (" - found replace: $name -> $sitename:$pagename")
		name2 := "$sitename:$pagename"
		return publisher.page_get(name2) or {panic(err)}

	}
	println(" >debug: D")

	if page_source.site_id  != page_dest.site_id {
		name3 := "$sitename:$pagename"
		if name3 != name.trim(" ") {
			page_source.replace_write(mut publisher, name, name3) or { return error(err) }
		}

	}

}