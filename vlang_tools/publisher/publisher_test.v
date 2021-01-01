import publisher

fn test_get_content_basic() {
	mut f := publisher.new()
	f.load('test', 'testcontent/site1')
	// IT CRASHES WHEN 2x using the same name, otherwise not
	// on a repo in my filesystem though it also crashed even with other name
	f.load('wiki', 'testcontent/site2')
	println(f.sites[1].pages)
	mut found := false
	// means roadmap page is in the found elements
	for page in f.sites[1].pages {
		if page.name == 'roadmap' {
			found = true
		}
	}
	assert found == true
	site5 := f.sites[1]
	assert site5.page_exists('roadmap')
	p := site5.page_get('roadmap') or { panic('cant find page') }
	println(p)
	site1, page1 := f.page_get('docker_Compatibility.md') or { panic('cannot find doc 1') }
	println(page1)
	site2, page2 := f.page_get('docker_Compatibility') or { panic('cannot find doc 2') }
	println(page2)
	site3, page3 := f.page_get('test:docker_Compatibility') or { panic('cannot find doc 3') }
	assert site1.name == site2.name
	assert site3.name == site2.name
	assert page3.name == page2.name
	assert page1.name == page2.name
	mut a := 1
	site4, page4 := f.page_get('test:docker_cCompatibility') or {
		a = 2
		return
	}
	assert a == 2
	assert f.sites.len == 2
	assert f.sites[1].name == 'wiki'
}

fn test_get_content1() {
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
	site2, pageobj := f.page_get('roadmap.md') or { panic(err) }
	// // this has enough info to serve the image back
	println(pageobj.path_get(site2))
	println(pageobj)
	// pages_test(mut f)
}
