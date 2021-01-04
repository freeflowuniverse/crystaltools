module main

import os
import vweb
import publisher

const (
	port = 8082
)

struct App {
pub mut:
	vweb     vweb.Context // TODO embed
	cnt      int
	publisher publisher.Publisher
}

// Run server
fn main() {
	vweb.run<App>(port)
}

// Initialize (load wikis) only once when server starts
pub fn (mut app App) init_once() {
	// gitstructure := new()
	// println(gitstructure)
	app.publisher = publisher.new("") or {panic("cannot init publisher. $err")}
	// app.publisher.load_all() or {panic("cannot loadaa publisher. $err")}// will find all sitename sites
	// println(app.publisher)
	// println('\nPublishing tools is running http://localhost:8082\n')
}

// Initialization code goes here (with each request)
pub fn (mut app App) init() {
}

// Index (List of wikis) -- reads index.html
pub fn (mut app App) index() vweb.Result {
	mut wikis := []string{}
	for site in app.publisher.sites {
		wikis << site.name
	}
	return $vweb.html()
}

[get]
['/:sitename']
pub fn (mut app App) get_wiki(sitename string) vweb.Result {
	mut site := app.publisher.site_get(sitename) or { return app.vweb.not_found() }
	path := site.path
	mut index := os.read_file( path + '/index.html') or {
		return app.vweb.not_found()
	}
	app.vweb.set_content_type('text/html')
	return app.vweb.ok(index)
}

[get]
['/:sitename/:filename']
pub fn (mut app App) get_wiki_file(sitename string, filename string) vweb.Result {
	if filename.starts_with("file__"){
		splitted := filename.split("__")
		if splitted.len != 3{
			return app.vweb.not_found() 
		}
		return app.get_wiki_img(splitted[1], splitted[2])
	}
	
	if filename.starts_with("page__"){
		splitted := filename.split("__")
		if splitted.len != 3{
			return app.vweb.not_found() 
		}
		return app.get_wiki_file(splitted[1], splitted[2])
	}

	mut site := app.publisher.site_get(sitename) or { return app.vweb.not_found() }
	root := site.path
	if filename.starts_with('_') {//why do we do this?
		mut file := os.read_file(os.join_path(root, filename)) or { return app.vweb.not_found() }
		app.vweb.set_content_type('text/html')
		return app.vweb.ok(file)
	} else {
		mut file := ''
		if filename.ends_with('.md') {
			app.vweb.set_content_type('text/html')
			mut pageobj := site.page_get(filename, mut &app.publisher) or {
				if filename == 'README.md' {
					file = os.read_file(os.join_path(root, '_sidebar.md')) or {
						return app.vweb.not_found()
					}
					app.vweb.set_content_type('text/html')
					return app.vweb.ok('# $sitename\n' + file)
				}
				return app.vweb.not_found()
			}
			file = pageobj.content
		} else {
			img := site.file_get(filename, mut app.publisher) or { return app.vweb.not_found() }
			//shouldn't we return as static, this brings everything in memory?
			file = os.read_file(img.path_get(mut &app.publisher)) or { return app.vweb.not_found() }
			extension := filename.split('.')[1]
			app.vweb.set_content_type('image/' + extension)
		}
		return app.vweb.ok(file)
	}
}

[get]
['/:sitename/img/:filename']
pub fn (mut app App) get_wiki_img(sitename string, filename string) vweb.Result {
	mut site := app.publisher.site_get(sitename) or { return app.vweb.not_found() }
	img := site.file_get(filename, mut &app.publisher) or { return app.vweb.not_found() }
	file := os.read_file(img.path_get(mut &app.publisher)) or { return app.vweb.not_found() }
	extension := filename.split('.')[1]
	app.vweb.set_content_type('image/' + extension)
	return app.vweb.ok(file)
}

[get]
['/:sitename/errors']
pub fn (mut app App) errors(sitename string) vweb.Result {
	mut site := app.publisher.site_get(sitename) or { return app.vweb.not_found() }
	// mut f := publisher.new()
	// f.lazy_loading = false
	// f.load(sitename, app.publisher.sites[sitename].path)
	app.publisher.check()
	site_errors := site.errors
	// page_erros := map[string]map[string]string{}
	
	return $vweb.html()
}
