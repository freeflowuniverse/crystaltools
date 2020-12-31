module publishingtools

struct Site {
pub mut:
	images map[string]Image
	pages  map[string]Page
	errors []SiteError
	path   string
	name   string
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
