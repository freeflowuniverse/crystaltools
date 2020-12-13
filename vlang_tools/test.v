import finder
fn main() {

	mut f := finder.get()

	println("start")
	// f.load("test","~/code/github/threefoldtech/info_tftech")
	// f.load("/tmp")
	f.load("test","testcontent/site1")


	// println(f.sites["test"])

	f.process()

	//argument will be comeo lowercase and remove '.md' at end
	pageresult1 := f.page_get("docker_Compatibility.md") or {println(err) return}
	pageresult2 := f.page_get("docker_Compatibility") or {println(err) return}
	println(pageresult2) 
	pageresult3 := f.page_get("test:docker_Compatibility") or {println(err) return}
	println(pageresult3)

	imageresult1 := f.image_get("network connectivity.png") or {println(err) return}
	println(imageresult1) 	


	// image = f.image_get("network_cconnectivity.png") or {println(err) return}
	// println(image) 		

}