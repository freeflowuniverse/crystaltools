import publisher

fn test_get_content_basic() {
	mut f := publisher.new()
	f.load_all("..") or {panic(err)}
	site5 := f.site_get("wiki")or { panic('cant find wiki') }
	assert site5.page_exists('roadmap')
	p := site5.page_get('roadmap') or { panic('cant find page') }
	// println(p)
	site1, page1 := f.page_get('docker_Compatibility.md') or { panic('cannot find doc 1') }
	// println(page1)
	site2, page2 := f.page_get('docker_Compatibility') or { panic('cannot find doc 2') }
	// println(page2)
	site3, page3 := f.page_get('test:docker_Compatibility') or { panic('cannot find doc 3') }
	assert site1.name == site2.name
	assert site3.name == site2.name
	assert page3.name == page2.name
	assert page1.name == page2.name
	mut a := 1
	_, _ := f.page_get('test:docker_cCompatibility') or {
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
	f.load_all("..") or {panic(err)}
	_, imageobj := f.image_get('blockchain_dilema.png') or { panic(err) }
	// this has enough info to serve the image back
	println(imageobj.path_get(mut &f))
	println(imageobj)
	_, pageobj := f.page_get('roadmap.md') or { panic(err) }
	// // this has enough info to serve the image back
	println(pageobj.path_get(mut &f))
	println(pageobj)
	// pages_test(mut f)
}


fn test_get_content2() {
	mut f := publisher.new()
	println('start')
	f.load_all("..") or {panic(err)}
	for site in f.sites{
		println(site.name)
	}
	assert f.sites.len == 2
	_, mut pageobj := f.page_get('roadmap.md') or { panic(err) }
	// // this has enough info to serve the image back
	println(pageobj.path_get(mut &f))
	e:=pageobj.markdown_get(mut &f)

	//check includes & links worked well
	assert e.contains("TFGrid release 2.1")
	assert e.contains("TFGrid release 2.2")
	assert e.contains("![](wiki:roadmap.png)")
}
