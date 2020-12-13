module finder

// import os
// import json


pub enum ImageStatus { unknown ok error }
struct Image {
	path 	string
	state 	ImageStatus
	nrtimes_used int
}


fn (mut image Image) process(){

}