module publisher

pub enum ImageStatus {
	unknown
	ok
	error
}

struct Image {
	name         string
	path         string
	state        ImageStatus
	nrtimes_used int
}
