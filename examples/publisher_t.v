import publisher

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
	assert f.sites.len == 2
	assert f.sites[1].name == 'wiki'
	site2, mut pageobj := f.page_get('roadmap.md') or { panic(err) }
	// // this has enough info to serve the image back
	println(pageobj.path_get(&f))
	e:=pageobj.markdown_get(&f)
	println(e)
	// pages_test(mut f)
	println(1)
}
