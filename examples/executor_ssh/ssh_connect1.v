	
module main

import freeflowuniverse.crystallib.builder
// import os
import sqlite
import freeflowuniverse.crystallib.terraform

fn do() ? {
	reset := false

	mut t := terraform.get('test') ?

	println(t)

	// mut app1 := builder.node_new(ipaddr:"46.101.149.252",name:"app1",debug:true,reset:reset)?
}

fn main() {
	do() or { panic(err) }
}
