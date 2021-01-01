module publisher

pub enum PageStatus {
	unknown
	ok
	error
}

struct Page {
pub:
	name            string
	path            string
pub mut:
	state           PageStatus
	errors          []PageError
	nrtimes_inluded int
	nrtimes_linked  int
	content         string
}

pub enum PageErrorCat {
	unknown
	brokenimage
	brokenlink
	brokeninclude
}

struct PageError {
	line   string
	linenr int
	msg    string
	cat    PageErrorCat
}
