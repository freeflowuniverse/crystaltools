module publisher

import os
import vweb
import myconfig
import json

//this webserver is used for looking at the builded results


const (
	port = 9998
)

struct App{
 	vweb.Context
pub mut:
 	cnt      int
 	publisherobj Publisher	 
}

struct ErrorJson{
		pub:
			site_errors []SiteError
			page_errors map [string][]PageError
	}


// Run server
pub fn webserver_start_build() {	
	vweb.run<App>(port){}
}

// Initialize (load wikis) only once when server starts
pub fn (mut app App) init_once() {
	//nothing to do because was already build in a step before, to the flattened directory
}

// Initialization code goes here (with each request)
pub fn (mut app App) init() {}

// Index (List of wikis) -- reads index.html
pub fn (mut app App) index() vweb.Result {
	mut wikis := []string{}
	configdata := myconfig.get()
	path := os.join_path(configdata.paths.publish)
	list := os.ls(path) or {panic(err)}

	for item in list{
			wikis << item
	}	

	return $vweb.html()
}

[get]
['/:sitename']
pub fn (mut app App) get_wiki(sitename string) vweb.Result {
	configdata := myconfig.get()
	path := os.join_path(configdata.paths.publish, sitename, "index.html")
	file := os.read_file(path) or {return app.not_found()}
	app.set_content_type('text/html')
	return app.ok(file)
}

[get]
['/:sitename/:filename']
pub fn (mut app App) get_wiki_file(sitename string, filename string) vweb.Result {
	configdata := myconfig.get()

	if filename.starts_with("file__"){
		splitted := filename.split("__")
		if splitted.len != 3{
			return app.not_found() 
		}
		return app.get_wiki_img(splitted[1], splitted[2])
	}
	
	if filename.starts_with("page__"){
		splitted := filename.split("__")
		if splitted.len != 3{
			return app.not_found() 
		}
		return app.get_wiki_file(splitted[1], splitted[2])
	}

	if filename.starts_with("html__"){
		mut splitted := filename.split("__")

		if splitted.len < 3{
			return app.not_found() 
		}

		path := os.join_path(configdata.paths.publish, splitted[1], splitted[2..].join("/"))
		mut f := os.read_file( path) or {return app.not_found()}
		app.set_content_type('text/html')
		return app.ok(f)	
	}

	root := os.join_path(configdata.paths.publish, sitename)
	if filename.starts_with('_') {//why do we do this?
		mut file := os.read_file(os.join_path(root, filename)) or { return app.not_found() }
		app.set_content_type('text/html')
		return app.ok(file)
	} else {
		mut file := ''
		if filename.ends_with('.md') {
			app.set_content_type('text/html')
			file = os.read_file(os.join_path(root, filename)) or {
				if filename == 'README.md' {
					file = os.read_file(os.join_path(root, '_sidebar.md')) or {
						return app.not_found()
					}
					app.set_content_type('text/html')
					return app.ok('# $sitename\n' + file)
				}
				return app.not_found()
			}
			return app.ok(file)

		} else {
			extension := filename.split('.')[1]
			app.set_content_type('image/' + extension)
			

		}
		
	}
	return app.not_found()
}

[get]
['/:sitename/img/:filename']
pub fn (mut app App) get_wiki_img(sitename string, filename string) vweb.Result {
	configdata := myconfig.get()
	path := os.join_path(configdata.paths.publish, sitename, filename)
	file := os.read_file(path) or {return app.not_found()}
	extension := filename.split('.')[1]
	app.set_content_type('image/' + extension)
	return app.ok(file)
}

[get]
['/:sitename/errors']
pub fn (mut app App) errors(sitename string) vweb.Result {
	configdata := myconfig.get()
	path := os.join_path(configdata.paths.publish, sitename, "errors.json")
	err_file := os.read_file(path) or {return app.not_found()}
	
	errors := json.decode(ErrorJson, err_file) or {return app.not_found()}
	
	mut site_errors := errors.site_errors
	mut page_errors := errors.page_errors

	return $vweb.html()
}

