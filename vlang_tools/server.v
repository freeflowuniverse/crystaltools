module main

import os
import vweb

import publishingtools


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

pub fn (mut app App) init_once() {}
pub fn (mut app App) init() {}
pub fn (mut app App) index() vweb.Result {return app.vweb.ok("Works!")}

[get]
['/:wiki']
pub fn (mut app App) get_wiki(wiki string) vweb.Result {
	mut index := os.read_file(getenv('HOME') + "/" + "code/github/threefoldfoundation/info_foundation/src/index.html") or { return app.vweb.not_found() }
	app.vweb.set_content_type("text/html")
	return app.vweb.ok(index)
}

[get]
['/:wiki/:filename']
pub fn (mut app App) get_wiki_file(wiki string, filename string) vweb.Result {
	mut root := getenv('HOME') + "/" + "code/github/threefoldfoundation/info_foundation/src/"
	mut pubtools := publishingtools.new()
	pubtools.load(wiki, root)
	pubtools.check()
	println(filename)
	pageobj := pubtools.page_get(filename) or {return app.vweb.not_found()}
	mut file := os.read_file(root + pageobj.page.path) or { return app.vweb.not_found() }
	app.vweb.set_content_type("text/html")
	return app.vweb.ok(file)
}

