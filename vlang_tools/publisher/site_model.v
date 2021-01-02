module publisher

struct Site {
	id        int 		  [skip]	// id and index in the Publisher.sites array
pub mut:
	// not in json if we would serialize
	images    []Image
	pages     []Page
	errors    []SiteError
	path      string
	name      string
}

pub enum SiteErrorCategory {
	duplicateimage
	duplicatepage
}

struct SiteError {
pub:
	path  string
	error string
	cat   SiteErrorCategory
}
