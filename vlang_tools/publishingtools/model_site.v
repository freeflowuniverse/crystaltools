module publishingtools

import os
// import json


struct Site{
	name 	string
	path 	string
	pub mut:
		images	map[string]Image
		pages	map[string]Page
		errors  []SiteError

}

pub enum SiteErrorCategory { duplicateimage duplicatepage}
struct SiteError {
	path 	string
	error	string
	cat 	SiteErrorCategory
}


