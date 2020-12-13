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
	mut page := f.page_get("docker_Compatibility.md") or {println(err) return}
	page = f.page_get("docker_Compatibility") or {println(err) return}
	println(page) 
	page = f.page_get("test:docker_Compatibility") or {println(err) return}
	println(page)

	// mut image := f.image_get("network_connectivity.png") or {println(err) return}
	// println(image) 	

	// image = f.image_get("network_cconnectivity.png") or {println(err) return}
	// println(image) 		

}