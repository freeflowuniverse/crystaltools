module publisher

struct Site {
	// id        int 		  [skip]	// id and index in the Publisher.sites array
pub mut:
	// not in json if we would serialize
	errors    []SiteError
	path      string
	name      string
	file_name_id map[string]int
	page_name_id map[string]int
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
	if namelower in site.page_name_id{
		return publisher.page_get_by_id(site.page_name_id[namelower])
	}
	return error('cannot find page with name $name')
}

pub fn (site Site) file_get(name string, mut publisher &Publisher) ?&File {
	mut namelower := name_fix(name)
	if namelower in site.file_name_id{
		return publisher.file_get_by_id(site.file_name_id[namelower])
	}
	return error('cannot find file with name $name')
}

pub fn (site Site) page_exists(name string) bool {
	mut namelower := name_fix(name)
	return namelower in site.page_name_id
}

pub fn (site Site) file_exists(name string) bool {
	mut namelower := name_fix(name)
	return namelower in site.file_name_id
}