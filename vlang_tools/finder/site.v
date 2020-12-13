module finder

import os
// import json


struct Site{
	pub mut:
		path 	string
		images	map[string]Image
		pages	map[string]Page

}

//remember the image, so we know if we have duplicates
fn (mut site Site) remember_image(path string, name string){
	mut namelower := name.to_lower()
	mut pathfull := os.join_path(path, name)
	// println( " - Image $pathfull" )
	site.images[name] = Image({ path: pathfull})
	image := site.images[namelower]
	println(image)

}

fn (mut site Site) remember_page(path string, name string){

	mut pathfull := os.join_path(path, name)
	// println( " - Page $pathfull" )

}
