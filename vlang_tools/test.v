import finder
fn main() {

	mut f := finder.get()

	println("start")
	// f.load("test","~/code/github/threefoldtech/info_tftech")
	// f.load("/tmp")
	f.load("wiki","testcontent/site1")

	// println(f.sites["test"])

	f.process()

	//argument will be comeo lowercase and remove '.md' at end
	mut page := f.page_get("docker_Compatibility.md") or {panic("S")}
	page = f.page_get("docker_Compatibility") or {panic("S")}
	println(page) 
	page = f.page_get("wiki:docker_Compatibility") or {panic("S")}

	// mut image := f.image_get("network_connectivity.png") or {panic("S")}
	// println(image) 	

	// image = f.image_get("network_cconnectivity.png") or {panic("S")}
	// println(image) 		

}