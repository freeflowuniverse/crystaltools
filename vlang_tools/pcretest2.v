import pcre

fn main() {

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

  //check the regex on https://regex101.com/r/HdYya8/1/

	r := pcre.new_regex('\[[\w \.\!]*\]\( *\w*\:*\w* *\)', 0) or {
		println('An error occured!')
		return
	}

	m := r.match_str(text, 0, 0) or {
		println('No match!')
		return
	}

	println(m.get_all())

  whole_match := m.get(0) or {
    println('We matched nothing...')
    return
  }

  // println(whole_match)

}