module main

// import despiegk.crystallib.fftools
// import despiegk.crystallib.git3
import despiegk.crystallib.terraform

fn do()? {
	mut tf := terraform.get()?
	// println(res)
}

fn main() {
	do() or {panic(err)}
	// fftools.install() or {panic(err)}
}
