module publishingtools

pub enum PageStatus { unknown ok error }
struct Page {
	path 	string
	mut:
		state 	PageStatus
		errors []PageError
		nrtimes_inluded int
		nrtimes_linked 	int
}

struct PageError {
	line	string
	linenr 	int
	msg	string
}

