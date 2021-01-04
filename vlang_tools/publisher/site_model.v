module publisher

struct Site {
id        int 	[skip]	  // id and index in the Publisher.sites array
pub mut:
	// not in json if we would serialize
	errors    []SiteError
	path      string
	name      string
	files map[string]int
	pages map[string]int
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
