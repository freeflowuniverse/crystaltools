module publishermod

import os

// make sure that the names are always normalized so its easy to find them back
pub fn name_fix(name string) string {
	mut pagename := name_fix_keepext(name)
	if pagename.ends_with('.md') {
		pagename = pagename[0..pagename.len - 3]
	}
	return pagename
}

pub fn name_fix_no_underscore(name string) string {
	mut pagename := name_fix_keepext(name)
	return pagename.replace('_', '')
}

pub fn name_fix_keepext(name string) string {
	mut pagename := name.to_lower()
	if '#' in pagename {
		pagename = pagename.split('#')[0]
	}
	// need to replace . to _ but not the last one (because is ext) (TODO:)
	pagename = pagename.replace(' ', '_')
	pagename = pagename.replace('-', '_')
	pagename = pagename.replace('__', '_')
	pagename = pagename.replace('__', '_') // needs to be 2x because can be 3 to 2 to 1
	pagename = pagename.replace(';', ':')
	pagename = pagename.replace('::', ':')
	pagename = pagename.trim(' .:')
	return pagename
}

// return (sitename,pagename)
// works for files & pages
pub fn name_split(name string) ?(string, string) {
	mut objname := name.trim(' ')
	objname = objname.trim_left('.')
	if objname.starts_with('file__') || objname.starts_with('page__') {
		objname = objname[6..]
		sitename := objname.split('__')[0]
		itemname := objname.split('__')[1]
		objname = '$sitename:$itemname'
	}
	// to deal with things like "img/tf_world.jpg ':size=300x160'"
	splitted0 := objname.split(' ')
	if splitted0.len > 0 {
		objname = splitted0[0]
	}
	objname = name_fix(objname)
	mut sitename := ''
	splitted := objname.split(':')
	if splitted.len == 1 {
		objname = splitted[0]
	} else if splitted.len == 2 {
		sitename = splitted[0]
		objname = splitted[1]
	} else {
		return error("name needs to be in format 'sitename:filename' or 'filename', now '$objname'")
	}
	objname = objname.trim_left('.')
	if '/' in objname {
		objname = os.base(objname)
		if objname.trim(' ') == '' {
			return error('objname empty for os.base')
		}
	}
	// make sure we don't have the e.g. img/ in
	if objname.ends_with('/') {
		return error("objname cannot end with /: now '$objname'")
	}
	if objname.trim(' ') == '' {
		return error('objname empty')
	}

	eprintln(" >> namesplit: '$sitename' '$objname'")

	return sitename, objname
}
