module main

import os
import vweb
import helpers
import publishingtools

const (
	port = 8082
)

struct App {
pub mut:
	vweb     vweb.Context // TODO embed
	cnt      int
	pubtools publishingtools.PublTools
}

// Run server
fn main() {
	vweb.run<App>(port)
}

// Initialize (load wikis) only once when server starts
pub fn (mut app App) init_once() {
	mut sites := helpers.list_repos()
	app.pubtools = publishingtools.new()
	for key, value in sites {
		mut name := key
		mut path := value['path']
		mut index := path + '/index.html'
		app.pubtools.load(name, path)
		app.pubtools.check()
	}
	println('\nPublishing tools is running http://localhost:8082\n')
}

// Initialization code goes here (with each request)
pub fn (mut app App) init() {
}

// Index (List of wikis) -- reads index.html
pub fn (mut app App) index() vweb.Result {
	mut wikis := []string{}
	for key, _ in app.pubtools.sites {
		wikis << key
	}
	return $vweb.html()
}

[get]
['/:wiki']
pub fn (mut app App) get_wiki(wiki string) vweb.Result {
	mut index := os.read_file(app.pubtools.sites[wiki].path + '/index.html') or {
		return app.vweb.not_found()
	}
	app.vweb.set_content_type('text/html')
	return app.vweb.ok(index)
}

[get]
['/:wiki/:filename']
pub fn (mut app App) get_wiki_file(wiki string, filename string) vweb.Result {
	mut root := app.pubtools.sites[wiki].path
	if filename.starts_with('_') {
		mut file := os.read_file(os.join_path(root, filename)) or { return app.vweb.not_found() }
		app.vweb.set_content_type('text/html')
		return app.vweb.ok(file)
	} else {
		mut file := ''
		if filename.ends_with('.md') {
			app.vweb.set_content_type('text/html')
			mut pageobj := app.pubtools.page_get('$wiki:$filename') or {
				if filename == "README.md"{
					file = os.read_file(os.join_path(root, "_sidebar.md")) or { return app.vweb.not_found() }
					app.vweb.set_content_type("text/html")
					return app.vweb.ok("# $wiki\n" + file)
				}
				return app.vweb.not_found() 
			}
			file = pageobj.markdown_get("")
		} else {
			img := app.pubtools.image_get('$wiki:$filename') or { return app.vweb.not_found() }
			file = os.read_file(img.path_get()) or { return app.vweb.not_found() }
			extension := filename.split('.')[1]
			app.vweb.set_content_type('image/' + extension)
		}
		return app.vweb.ok(file)
	}
}

[get]
['/:wiki/img/:filename']
pub fn (mut app App) get_wiki_img(wiki string, filename string) vweb.Result {
	img := app.pubtools.image_get(filename) or { return app.vweb.not_found() }
	file := os.read_file(img.path_get()) or { return app.vweb.not_found() }
	extension := filename.split('.')[1]
	app.vweb.set_content_type('image/' + extension)
	return app.vweb.ok(file)
}
