import publishingtools
import pcre

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
	f.load("test","testcontent/site1")
	//IT CRASHES WHEN 2x using the same name, otherwise not
	// on a repo in my filesystem though it also crashed even with other name
	f.load("wiki","testcontent/site2")
	// f.load("wiki","~/code/github/threefoldfoundation/info_foundation/src")


	// f.check()

	// pageactors_test(mut f)

	// query := '\[(.*)\]\( *(\w*\:*\w*) *\)'
	// query := '\[(.*)\]\( *(\w*\:*\w*) *\)'

	// query := r'this (\w+) a'

	// query := r'\[.*\]\( *\w*\:*\w+ *\)'
	// query := '\[.*\]\( *\w*\:*\w+ *\)'

	text := "[ an s. s! ]( wi4ki:something )
	[ an s. s! ]( wi4ki:something )
	[ an s. s! ](wiki:something)
	[ an s. s! ](something)dd
	d [ an s. s! ](something ) d
	[  more text ]( something )  [ something b ](something)dd

	"

	r := pcre.new_regex('\[(.*)\]\( *(\w*\:*\w*) *\)', 0) or {
		println('An error occured!')
		return
	}

	m := r.match_str(text, 0, 0) or {
		println('No match!')
		return
	}

	println(m)

	// mut re := regex.regex_opt(query) or { panic(err) }

	// mut re := regex.new()
	// re.compile_opt(query) or { panic(err) }

	// re.debug = 1 // set debug on at minimum level
	// println('#query parsed: $re.get_query()')
	// re.debug = 0

	// for x in re.find_all(text){
	// 	println(x)
	// }



}