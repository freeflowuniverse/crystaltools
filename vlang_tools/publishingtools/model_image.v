module publishingtools

pub enum ImageStatus { unknown ok error }
struct Image {
	path 	string
	state 	ImageStatus
	nrtimes_used int
}

