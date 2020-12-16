module main

import os
import vweb

import publishingtools


const (
	port = 8082
)

struct Wiki {
	pub mut:
		name string
		path string
		index string
		pubtools publishingtools.PublTools
}

struct App {

pub mut:
	vweb vweb.Context // TODO embed
	cnt  int
	wikis map[string]Wiki
}


fn main() {
	vweb.run<App>(port)
}

pub fn (mut app App) init_once() {
	app.wikis = map[string]Wiki{}
	mut pubtools :=  publishingtools.new() 
	mut root := getenv('HOME') + "/" + "code/github/threefoldfoundation/info_foundation/src/"
	mut index := root + "index.html"
	pubtools.load("info_foundation", root)
	pubtools.check()
	mut wiki := Wiki{name: "info_foundation", path: root, index: index, pubtools: &pubtools}
	app.wikis["info_foundation"] = wiki
}

pub fn (mut app App) init() {}
pub fn (mut app App) index() vweb.Result {return app.vweb.ok("Works!")}

[get]
['/:wiki']
pub fn (mut app App) get_wiki(wiki string) vweb.Result {
	mut index := os.read_file(app.wikis[wiki].index) or { return app.vweb.not_found() }
	app.vweb.set_content_type("text/html")
	return app.vweb.ok(index)
}

[get]
['/:wiki/:filename']
pub fn (mut app App) get_wiki_file(wiki string, filename string) vweb.Result {
	mut wiki_obj := app.wikis[wiki]

	if filename.starts_with("_"){
		mut file := os.read_file(wiki_obj.path + filename) or { return app.vweb.not_found() }
		app.vweb.set_content_type("text/html")
		return app.vweb.ok(file)
	}else{
		pageobj := wiki_obj.pubtools.page_get(filename) or {return app.vweb.not_found()}
		mut file := os.read_file(wiki_obj.path + pageobj.page.path) or { return app.vweb.not_found() }
		app.vweb.set_content_type("text/html")
		return app.vweb.ok(file)
	}
}

