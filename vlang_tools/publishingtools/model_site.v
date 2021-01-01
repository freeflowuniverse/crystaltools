module publishingtools

struct Site {
pub mut:
	images []Image
	pages  []Page
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
