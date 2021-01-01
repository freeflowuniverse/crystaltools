import publisher

fn pages_test(mut f publisher.Publisher) {
	// println(f.sites["test"])
	// argument will be comeo lowercase and remove '.md' at end
	site1, page1 := f.page_get('docker_Compatibility.md') or {
		println(err)
		return
	}
	println(page1)
	site2, page2 := f.page_get('docker_Compatibility') or {
		println(err)
		return
	}
	println(page2)
	site3, page3 := f.page_get('test:docker_Compatibility') or {
		println(err)
		return
	}
	println(page3)
	site4, image1 := f.image_get('network-connectivity.png') or {
		println(err)
		return
	}
	println(image1)
}

fn main() {
	mut f := publisher.new()
	println('start')
	// f.load("tech","~/code/github/threefoldtech/info_tftech")
	// f.load("/tmp")
	f.load('test', 'testcontent/site1')
	// IT CRASHES WHEN 2x using the same name, otherwise not
	// on a repo in my filesystem though it also crashed even with other name
	f.load('wiki', 'testcontent/site2')
	// f.load("wiki","~/code/github/threefoldfoundation/info_foundation/src")	
	// f.check()
	site, imageobj := f.image_get('smart_contract_it.png') or { panic(err) }
	// this has enough info to serve the image back
	println(imageobj.path_get(site))
	println(imageobj)
	// now serve the wiki server and /wiki/...communication_header.jpg should serve this file
	//`...` means anything
	// pageobj := f.page_get('collaboration.md') or { panic(err) }
	// // this has enough info to serve the image back
	// println(pageobj.path_get())
	// println(pageobj.page)
	// pages_test(mut f)
}
