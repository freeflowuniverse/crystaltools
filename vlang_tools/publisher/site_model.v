module publisher
import regex

struct Site {
id        int 	[skip]	  // id and index in the Publisher.sites array
pub mut:
	// not in json if we would serialize
	errors    []SiteError
	path      string
	name      string
	files map[string]int
	pages map[string]int
	state 	  SiteState
	replace	  SiteReplace
	config 	  SiteConfig
}

pub enum SiteErrorCategory {
	duplicatefile
	duplicatepage
}

struct SiteError {
pub:
	path  string
	error string
	cat   SiteErrorCategory
}

pub enum SiteState {
	init
	ok
	error
}		

struct SiteConfig {
	// name of the wiki site
	name    string
	// depends on which other wiki sites
	depends []string
	replace []string
	filechanges []string
}


pub struct SiteReplace {
pub mut:
	replace_items []ReplaceItem
	namechanges []NameChange
}

pub struct NameChange {
pub mut:
	name string
	replace string
}

pub struct ReplaceItem {
pub mut:
	query regex.RE
	replace string
}

fn (mut config SiteReplace) replace_add(query string , replace string) {
	mut re := regex.new()
	re.compile_opt("${query.trim(' ')}") or { panic(err) }	
	config.replace_items << ReplaceItem{query:re,replace:replace.trim(" ")}
}

fn (mut config SiteReplace) name_change(name string , replace string) {
	mut name2 := name_fix(name)
	mut replace2 := name_fix(replace)
	config.namechanges << NameChange{name:name2,replace:replace2}
}

pub fn (mut site Site) replace(text string) string {
	mut out := text
	mut found := ""
	for mut item in site.replace.replace_items {
		mut gi := 0
		mut all := item.query.find_all(text)
		// println("Query : ${item.query.get_query()}")
		for gi < all.len {
			found = text[all[gi]..all[gi + 1]]
			println('...:$found:')
			out = out.replace(found,item.replace)
			gi += 2
		}
		// println('')		
	}
	return out
}

//check there is a name change
pub fn (mut site Site) name_change_check(name string) bool {
	mut name2 := name_fix(name)
	for mut item in site.replace.namechanges {
		if name2 == item.name{
			return true
		}
	}
	return false
}

//check there is a name change (return empty string if not)
pub fn (mut site Site) name_fix_alias(name string) string {
	mut name2 := name_fix(name)
	for mut item in site.replace.namechanges {
		if name2 == item.name{
			return item.replace
		}
	}
	return name2
}

//init all replace items in the config file, populate the regex'es
pub fn (mut site Site) replace_init() ? {
	site.replace = SiteReplace{}
	for filechange in site.config.filechanges{
		if ":" in filechange{
			splitted := filechange.split(":")
			if splitted.len != 2 {
				return error("there can only be 1 : in replace, now '$filechange'")
			}
			site.replace.name_change(splitted[0],splitted[1])
		}else{
			return error("need to have : in filechange, now '$filechange'")
		}
	}

	for rename in site.config.replace{
		if ":" in rename{
			splitted := rename.split(":")
			if splitted.len != 2 {
				return error("there can only be 1 : in rename, now '$rename'")
			}
			site.replace.replace_add(splitted[0],splitted[1])
		}else{
			return error("need to have : in rename, now '$rename'")
		}
	}	

}





pub fn (site Site) page_get(name string, mut publisher &Publisher) ?&Page {
	mut namelower := name_fix(name)
	if namelower in site.pages{	
		return publisher.page_get_by_id(site.pages[namelower])
	}
	return error('cannot find page with name $name')
}

pub fn (site Site) file_get(name string, mut publisher &Publisher) ?&File {
	mut namelower := name_fix(name)
	if namelower in site.files{
		return publisher.file_get_by_id(site.files[namelower])
	}
	return error('cannot find file with name $name')
}

pub fn (site Site) page_exists(name string) bool {
	mut namelower := name_fix(name)
	return namelower in site.pages
}

pub fn (site Site) file_exists(name string) bool {
	mut namelower := name_fix(name)
	return namelower in site.files
}
