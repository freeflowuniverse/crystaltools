module publisher

import os
import json
import myconfig

struct PublisherErrors {
pub mut:
	site_errors []SiteError
	page_errors map[string][]PageError
}

// destination is the destination path for the flatten operation
pub fn (mut publisher Publisher) flatten()? {

	mut errors := PublisherErrors{}
	mut dest_file := ''

	mut config := myconfig.get()

	publisher.check() // makes sure we checked all

	for mut site in publisher.sites {
		errors = PublisherErrors{}

		site.files_process(mut publisher) ?

		// src_path[site.id] = site.path
		mut dest_dir := config.path_publish_wiki_get(site.name) ?
		println(" - flatten: $site.name to $dest_dir")

		// collect all errors in a datastruct
		for err in site.errors {
			// errors.site_errors << err
			// TODO: clearly not ok, the duplicates files check is not there
			if err.cat != SiteErrorCategory.duplicatefile
				&& err.cat != SiteErrorCategory.duplicatepage {
				errors.site_errors << err
			}
		}

		for name, _ in site.pages {
			page := site.page_get(name, mut publisher) ?
			if page.errors.len > 0 {
				errors.page_errors[name] = page.errors
			}
		}

		if !os.exists(dest_dir) {
			os.mkdir_all(dest_dir) ?
		}
		// write the json errors file
		os.write_file('$dest_dir/errors.json', json.encode(errors)) ?

		mut site_config := config.site_wiki_get(site.name) ?

		index_wiki_save(dest_dir,site.name,site_config.url)

		mut special := ['readme.md', 'README.md', '_sidebar.md', '_navbar.md','sidebar.md', 'navbar.md']

		// renameitems := [["_sidebar.md","sidebar.md"],["_navbar.md","navbar.md"]]
		// for ffrom,tto in renameitems{
		// 	if os.exists('$site.path/$ffrom'){
		// 		if os.exists('$site.path/$tto'){
		// 			os.rm('$site.path/$ffrom') ?
		// 		}else{
		// 			os.cp('$site.path/$ffrom','$site.path/$tto')?
		// 		}				
		// 		os.rm('$site.path/$ffrom')?
		// 	}
		// }

		for file in special {
			dest_file = file
			if os.exists('$site.path/$file') {
				if dest_file.starts_with('_') {
					dest_file = dest_file[1..] // remove the _
				}
				println("copy: $site.path/$file $dest_dir/$dest_file")
				os.cp('$site.path/$file', '$dest_dir/$dest_file') ?
			}
		}

		for name, _ in site.pages {
			mut page := site.page_get(name, mut publisher) ?
			content := page.content
			dest_file = os.join_path(dest_dir, os.file_name(page.path))
			os.write_file(dest_file, content) ?
		}

		for name, _ in site.files {
			mut fileobj := site.file_get(name, mut publisher) ?
			dest_file = os.join_path(dest_dir, os.file_name(fileobj.path))
			os.cp(fileobj.path_get(mut publisher), dest_file) ?
		}
	}
}
