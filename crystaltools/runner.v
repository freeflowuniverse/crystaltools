module main

// import os
import os.cmdline
import freeflowuniverse.crystallib.publisher_core

fn do() ? {
	options := os.cmdline.only_non_options()

	if options.len != 1 {
		println(' ERROR: please specify the path of the markdown actions file to start from')
	}

	// get a publisher & run it
	mut publ := publisher_core.run(actions_path: options[0]) ?
}

fn main() {
	do() or { panic(err) }
}
