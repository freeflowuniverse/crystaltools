module publisher

pub enum ImageStatus {
	unknown
	ok
	error
}

pub struct Image {
pub mut:
	name         string
	path         string
	state        ImageStatus
	nrtimes_used int
}
