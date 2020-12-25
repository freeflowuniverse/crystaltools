module texttools

import regex



//make sure to use r'regex' for the regex string !!!
fn replace(query string, toreplacewith string ) {

	mut re := regex.new()
	re.compile_opt(query) or { panic(err) }	

	

}