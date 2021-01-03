module publisher

pub enum FileStatus {
	unknown
	ok
	error
}

pub struct File {
// id        int 	[skip]
site_id   int 	[skip]
pub mut:
	name         string
	path         string
	state        FileStatus
	usedby 		 []int //names of pages which use this file
}


pub fn (page File) site_get(mut publisher &Publisher) ?&Site {
	return publisher.site_get_by_id(file.site_id)
}

