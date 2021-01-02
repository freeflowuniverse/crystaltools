module publisher

pub enum ImageStatus {
	unknown
	ok
	error
}

pub struct Image {
id        int 	[skip]
pub mut:
	name         string
	path         string
	state        ImageStatus
	nrtimes_used int
}
