module publishermod

import os

fn (mut publ Publisher) name_fix_alias_page(name string) ?string {
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

fn (mut publ Publisher) name_split_alias(name string) ?(string, string) {
	mut site_name, mut obj_name := name_split(name) ?
	site_name = publ.name_fix_alias_site(site_name) ?
	ext := os.file_ext(obj_name).trim('.')
	if ext == '' || ext == 'md' {
		obj_name = publ.name_fix_alias_page(obj_name) ?
	} else {
		obj_name = publ.name_fix_alias_file(obj_name) ?
	}
	return site_name, obj_name
}

// check if the file can be found and add the file to the site if needed
// it will also rename the file if needed
fn (mut publisher Publisher) file_check_fix(name2find string, consumer_page_id int) ?&File {
	consumer_page := publisher.page_get_by_id(consumer_page_id) or { panic(err) }
	mut consumer_site := consumer_page.site_get(mut publisher) or { panic(err) }

	mut filesres := publisher.files_get(name2find)
	if filesres.len == 0 {
		return error('cannot find the file: $name2find')
	}
	for mut f in filesres {
		if f.site_id == consumer_site.id {
			// we found a file in the right site, nothing to do
			f.consumer_page_register(consumer_page_id, mut publisher)
			file2 := publisher.file_get_by_id(f.id) ?
			// println(file2)
			return file2
		}
	}
	// means we found files but we don't have it in our site, we need to copy
	file_source := filesres[0]
	file_source_path := file_source.path_get(mut publisher)
	dest := '$consumer_site.path/img_tosort/${os.base(file_source_path)}'
	os.cp(file_source_path, dest) or { panic(err) }

	// will remember new file and will make sure rename if needed happens, but should already be ok
	file := consumer_site.file_remember_full_path(dest, mut publisher)

	// we know the name is in right site
	return file
}

// check if we can find the file, if not copy to site if found in other site
// we check the file based on name & replaced version of name
fn (mut publisher Publisher) file_check_find(name2find string, consumer_page_id int) ?&File {
	// didn't find a better way how to do it, more complicated than it should I believe 
	for x in 0 .. 3 {
		if x == 0 {
			zzz := publisher.file_check_fix(name2find, consumer_page_id) or { continue }
			return zzz
		}
		_, mut objname := name_split(name2find) or { panic(err) }
		if x == 1 {
			zzz := publisher.file_check_fix(objname, consumer_page_id) or { continue }
			return zzz
		}
		objname_replaced := publisher.replacer.file.replace(objname) or { panic(err) }
		if x == 2 {
			zzz := publisher.file_check_fix(objname_replaced, consumer_page_id) or { continue }
			return zzz
		}
	}

	// we did not manage to find a file, not even after replace
	return error('cannot find the file: $name2find')
}

// check if the page can be found over all sites
fn (mut publisher Publisher) page_check_fix(name2find string, consumer_page_id int) ?&Page {
	mut consumer_page := publisher.page_get_by_id(consumer_page_id) or { panic(err) }
	// mut consumer_site := consumer_page.site_get(mut publisher) or { panic(err) }
	mut res := publisher.pages_get(name2find)

	if res.len == 0 {
		return error('cannot find the page: $name2find')
	}
	if res.len > 1 {
		// we found more than 1 result, not ok cannot continue
		mut msg := 'we found more than 1 page for $name2find in $consumer_page.name, doubles found:\n '
		for p in res {
			msg += '$p.name ,'
		}
		msg = msg.trim(',')
		consumer_page.error_add({ msg: msg, cat: PageErrorCat.doublepage }, mut publisher)
		return error('found more than 1 page: $name2find')
	}
	return res[0]
}

// check if we can find the page, page can be on another site
// we check the page based on name & replaced version of name
fn (mut publisher Publisher) page_check_find(name2find string, consumer_page_id int) ?&Page {
	_, mut objname := name_split(name2find) or { panic(err) }
	mut objname_replaced := publisher.replacer.file.replace(objname) or { panic(err) }

	// didn't find a better way how to do it, more complicated than it should I believe 
	for x in 0 .. 5 {
		if x == 0 {
			zzz := publisher.page_check_fix(name2find, consumer_page_id) or { continue }
			return zzz
		}

		if x == 1 {
			zzz := publisher.page_check_fix(objname, consumer_page_id) or { continue }
			return zzz
		}

		if x == 2 {
			zzz := publisher.page_check_fix(objname_replaced, consumer_page_id) or { continue }
			return zzz
		}

		if x == 3 {
			// lets now try if we can get if from definitions
			zzz := publisher.def_page_get(objname) or { continue }
			return zzz
		}

		if x == 4 {
			// lets now try if we can get if from definitions
			zzz := publisher.def_page_get(objname_replaced) or { continue }
			return zzz
		}
	}
	// we did not manage to find a page, not even after replace
	return error('cannot find the file: $name2find')
}
