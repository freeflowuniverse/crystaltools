module publisher

struct Site {
	id        int 		  [skip]	// id and index in the Publisher.sites array
pub mut:
	// not in json if we would serialize
	files    []File
	pages     []Page
	errors    []SiteError
	path      string
	name      string
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
