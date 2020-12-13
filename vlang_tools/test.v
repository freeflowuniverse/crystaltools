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
	// f.load("test","~/code/github/threefoldtech/info_tftech")
	// f.load("/tmp")
	f.load("test","testcontent/site1")


	f.process()

	// pageactors_test(mut f)


}