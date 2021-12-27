	
module main
import despiegk.crystallib.builder
// import os
import sqlite
import despiegk.crystallib.terraform

fn do()?{


	//brew install sqlite
	path := "/Users/despiegk/Documents/Publii/sites/ourverse/input/db.sqlite"

	mut db := sqlite.connect(path)?

	r,nr:=db.exec("select * from posts;")

	println(r)


}

fn main() {
	do() or {panic(err)}
}


