import pcre

fn main() {

	// query := '\[(.*)\]\( *(\w*\:*\w*) *\)'
	// query := '\[(.*)\]\( *(\w*\:*\w*) *\)'

	// query := r'this (\w+) a'

	// query := r'\[.*\]\( *\w*\:*\w+ *\)'
	// query := '\[.*\]\( *\w*\:*\w+ *\)'

	mut text := "[ an s. s! ]( wi4ki:something )
	[ an s. s! ]( wi4ki:something )
	[ an s. s! ](wiki:something)
	[ an s. s! ](something)dd
	d [ an s. s! ](something ) d
	[  more text ]( something ) s [ something b ](something)dd

	"

  //check the regex on https://regex101.com/r/HdYya8/1/

	regex := r'(\[[a-z\.\! ]*\]\( *\w*\:*\w* *\))*'
	// regex := '.*'

	r := pcre.new_regex(regex, 0) or {
		println('An error occured!')
		return
	}

	text = "[  more text ]( something )  [ something b ](something)dd"
	// text = " [ an s. s! ](something)dd"
	m := r.match_str(text, 0, 0) or {
		println('No match!')
		return
	}

	whole_match1 := m.get(0) or {
    	println('We matched nothing 0...')
		return
  	}


	// whole_match2 := m.get(1) or {
    // 	println('We matched nothing 1...')
	// 	return
  	// }



	println(whole_match1)
	// println(whole_match2)

	println(m.get_all())

//   whole_match := m.get(0) or {
//     println('We matched nothing...')
//     return
//   }

  // println(whole_match)

}