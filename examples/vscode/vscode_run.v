module main

import freeflowuniverse.crystallib.ffeditor
import os

fn do() ? {
	println('start')
}

fn main() {
	do() or { panic(err) }
}
