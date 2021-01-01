module publishingtools

struct Site {
publtools &PublTools [skip] //not in json if we would serialize	
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
