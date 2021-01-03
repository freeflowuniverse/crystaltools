import publisher

fn main() {
	mut f := publisher.new()
	f.load('test', 'testcontent/site1') or {panic("canot load the wiki,$err")}
	// IT CRASHES WHEN 2x using the same name, otherwise not
	// on a repo in my filesystem though it also crashed even with other name
	f.load('wiki', 'testcontent/site2')or {panic("canot load the wiki,$err")}
	site5 := f.site_get("wiki")or { panic('cant find wiki') }
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
	_, _ := f.page_get('test:docker_cCompatibility') or {
		a = 2
		return
	}
	assert a == 2
	assert f.sites.len == 2
	assert f.sites[1].name == 'wiki'
}
