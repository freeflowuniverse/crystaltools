module publisher

pub enum FileStatus {
	unknown
	ok
	error
}

pub struct File {
id        int 	[skip]
site_id   int 	[skip]
pub mut:
	name         string
	path         string
	state        FileStatus
	usedby 		 []string //names of pages which use this file
}
