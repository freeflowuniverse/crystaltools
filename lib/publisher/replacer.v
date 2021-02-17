module publishermod

import os

fn (mut publ Publisher) name_fix_alias_name(name string) ?string {
	// name0 := name
	name0 := publ.replacer.file.replace(name) ?
	return name_fix(name0)
}

fn (mut publ Publisher) name_fix_alias_site(name string) ?string {
	name0 := publ.replacer.site.replace(name) ?
	return name_fix(name0)
}

fn (mut publ Publisher) name_fix_alias_file(name string) ?string {
	name0 := publ.replacer.file.replace(name) ?
	return name_fix_keepext(name0)
}

fn (mut publ Publisher) name_fix_alias_word(name string) ?string {
	name0 := publ.replacer.file.replace(name) ?
	return name0.trim(' ')
}

// check the name and fix if needed for page
pub fn (mut publisher Publisher) name_fix_check_page(name string, site_id int) ?string {
	return publisher.name_fix_check(name, site_id, true)
}

pub fn (mut publisher Publisher) name_fix_check_file(name string, site_id int) ?string {
	return publisher.name_fix_check(name, site_id, false)
}

// check the name and fix if needed for file
pub fn (mut publisher Publisher) name_fix_check(name string, site_id int, ispage bool) ?string {
	mut name2 := name
	mut ps := ExistState.error

	mut sitename, mut pagename := name_split(name2) ?

	// make sure we don't have the e.g. img/ in
	if '/' in pagename {
		pagename = os.base(pagename)
	}

	if sitename == '' {
		site := publisher.site_get_by_id(site_id) ?
		sitename = site.name
	}
	// first try the full name
	name2 = '$sitename:$pagename'
	ps = publisher.page_file_exists_state(name2, ispage)

	if ps != ExistState.ok {
		// lets now see if we can do one for page alone (if double will 
		name2 = pagename
		ps = publisher.page_file_exists_state(name2, ispage)
	}

	if ps != ExistState.ok {
		sitename_replaced := publisher.replacer.site.replace(sitename) ?
		pagename_replaced := publisher.replacer.file.replace(pagename) ?
		name2 = '$sitename_replaced:$pagename_replaced'
		ps = publisher.page_file_exists_state(name2, ispage)
	}
	if ps != ExistState.ok {
		pagename_replaced := publisher.replacer.file.replace(pagename) ?
		name2 = pagename_replaced
		ps = publisher.page_file_exists_state(name2, ispage)
	}

	if ispage {
		// lets now try if we can get if from definitions
		if ps != ExistState.ok {
			page3 := publisher.def_page_get(pagename) ?
			pagename3 := page3.name
			site3 := publisher.site_get_by_id(page3.site_id) ?
			sitename3 := site3.name
			name2 = '$sitename3:$pagename3'
			ps = publisher.page_file_exists_state(name2, ispage)
		}
		// lets now try if we can get if from definitions after doing the aliasses
		if ps != ExistState.ok {
			pagename_replaced := publisher.replacer.file.replace(pagename) ?
			page4 := publisher.def_page_get(pagename_replaced) ?
			pagename4 := page4.name
			site4 := publisher.site_get_by_id(page4.site_id) ?
			sitename4 := site4.name
			name2 = '$sitename4:$pagename4'
			ps = publisher.page_file_exists_state(name2, ispage)
		}
	}
	if ps != ExistState.ok {
		return error('Could not find page or file. $name')
	}

	mut namedest := ''
	mut siteid_dest := 0
	if ispage {
		page_dest := publisher.page_get(name2) ?
		namedest = page_dest.name
		siteid_dest = page_dest.site_id
	} else {
		file_dest := publisher.file_get(name2) ?
		namedest = file_dest.name
		siteid_dest = file_dest.site_id
	}

	if site_id != siteid_dest {
		name5 := namedest
		site5 := publisher.site_get_by_id(siteid_dest) ?
		sitename5 := site5.name
		return '$sitename5:$name5'
	}
	return '$namedest'
}
