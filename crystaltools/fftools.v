module main

import freeflowuniverse.crystallib.fftools
import freeflowuniverse.crystallib.git3

fn do()? {
	mut gh := git3.new(3600)?
	// res := gh.get_json_str("orgs/threefoldfoundation/repos","",true)?
	// res := gh.get_json_str("gists","",true)?
	println(res)
}

fn main() {
	do() or {panic(err)}
	// fftools.install() or {panic(err)}
}
