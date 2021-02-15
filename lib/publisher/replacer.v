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

// check the name and fix if needed
pub fn (mut publisher Publisher) name_fix(name string, site_id int) ?string {
	mut name2 := name
	mut ps := PageState.error

	mut sitename, mut pagename := name_split(name2) ?

	if sitename == '' {
		site := publisher.site_get_by_id(site_id) ?
		sitename = site.name
	}
	// first try the full name
	name2 = '$sitename:$pagename'
	ps = publisher.page_state(name2)

	if ps != PageState.ok {
		// lets now see if we can do one for page alone (if double will 
		name2 = pagename
		ps = publisher.page_state(name2)
	}

	if ps != PageState.ok {
		sitename_replaced := publisher.replacer.site.replace(sitename) ?
		pagename_replaced := publisher.replacer.file.replace(pagename) ?
		name2 = '$sitename_replaced:$pagename_replaced'
		ps = publisher.page_state(name2)
	}

	if ps != PageState.ok {
		pagename_replaced := publisher.replacer.file.replace(pagename) ?
		name2 = pagename_replaced
		ps = publisher.page_state(name2)
	}
	// lets now try if we can get if from definitions
	if ps != PageState.ok {
		page3 := publisher.def_page_get(pagename) ?
		pagename3 := page3.name
		site3 := publisher.site_get_by_id(page3.site_id) ?
		sitename3 := site3.name
		name2 = '$sitename3:$pagename3'
		ps = publisher.page_state(name2)
	}
	// lets now try if we can get if from definitions after doing the aliasses
	if ps != PageState.ok {
		pagename_replaced := publisher.replacer.file.replace(pagename) ?
		page4 := publisher.def_page_get(pagename_replaced) ?
		pagename4 := page4.name
		site4 := publisher.site_get_by_id(page4.site_id) ?
		sitename4 := site4.name
		name2 = '$sitename4:$pagename4'
		ps = publisher.page_state(name2)
	}

	if ps != PageState.ok {
		return error('Could not find page $name not from definitions or page name.\n')
	}

	page_dest := publisher.page_get(name2) ?

	if site_id != page_dest.site_id {
		pagename5 := page_dest.name
		site5 := publisher.site_get_by_id(page_dest.site_id) ?
		sitename5 := site5.name
		return '$sitename5:$pagename5'
	}
	return '$page_dest.name'
}
