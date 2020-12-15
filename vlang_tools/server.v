module main

import os
import vweb

const (
	port = 8082
)

struct App {

pub mut:
	vweb vweb.Context // TODO embed
	cnt  int
}

fn main() {
	println('vweb example')
	vweb.run<App>(port)
}


pub fn (mut app App) init_once() {
	
}


pub fn (mut app App) index() vweb.Result {
	mut f := os.read_file('./testcontent/site1/index.html') or { panic(err) }
	app.vweb.set_content_type("text/html")
	return app.vweb.ok(f)
}

[get]
['/:filename']
pub fn (mut app App) get_md(filename string ) vweb.Result {
	mut f := os.read_file('./testcontent/site1/' + filename) or { return app.vweb.not_found() }
	app.vweb.set_content_type("text/html")
	return app.vweb.ok(f)
}

pub fn (mut app App) init() {
}

