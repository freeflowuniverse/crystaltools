import publishingtools

fn pageactors_test(mut f &publishingtools.PublTools){

	// println(f.sites["test"])

	//argument will be comeo lowercase and remove '.md' at end
	pageactor1 := f.page_get("docker_Compatibility.md") or {println(err) return}
	println(pageactor1.page) 

	pageactor2 := f.page_get("docker_Compatibility") or {println(err) return}
	println(pageactor2.page) 
	pageactor3 := f.page_get("test:docker_Compatibility") or {println(err) return}
	println(pageactor3.page)

	imageactor1 := f.image_get("network-connectivity.png") or {println(err) return}
	println(imageactor1.image) 	

	

}


fn main() {

	mut f := publishingtools.new()

	println("start")
	// f.load("tech","~/code/github/threefoldtech/info_tftech")
	// f.load("/tmp")
	// f.load("test","testcontent/site1")
	//IT CRASHES WHEN 2x using the same name, otherwise not
	// on a repo in my filesystem though it also crashed even with other name
	// f.load("wiki","testcontent/site2")

	f.load("wiki","~/code/github/threefoldfoundation/info_foundation/src")


	f.check()

	imageobj := f.image_get("communication_header.jpg") or {panic(err)}
	//this has enough info to serve the image back
	println(imageobj.path_get())
	println(imageobj.image)

	//now serve the wiki server and /wiki/...communication_header.jpg should serve this file
	//`...` means anything

	pageobj := f.page_get("getinvolved.md") or {panic(err)}
	//this has enough info to serve the image back
	println(pageobj.path_get())	
	println(pageobj.page)	

	// pageactors_test(mut f)



}