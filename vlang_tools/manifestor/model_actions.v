module builder

import json

// THE OBJECT TO KEEP STATE FOR ANY NODE
pub enum PlatformType { unknown osx ubuntu alpine }


struct Node {
	//the unique identifier of the builder object
	key string
	pub mut:
		//to see what was already done and what not
		done map[string]bool
		platform 	PlatformType
		gitrepos map[string]GitRepo
}

