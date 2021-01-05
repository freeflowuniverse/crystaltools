module publisher

pub enum PageStatus {
	unknown
	ok
	error
}

struct Page {
id      int  [skip]
site_id int [skip]
pub:
	name            string
	path            string
pub mut:
	state           PageStatus
	errors          []PageError
	pages_included []int //links to pages
	pages_linked  []int //links to pages
	content         string
	nrtimes_inluded int
}

pub enum PageErrorCat {
	unknown
	brokenfile
	brokenlink
	brokeninclude
}

struct PageError {
	pub:
		line   string
		linenr int
		msg    string
		cat    PageErrorCat
}


pub fn (page Page) site_get(mut publisher &Publisher) ?&Site {
	return publisher.site_get_by_id(page.site_id)
}

