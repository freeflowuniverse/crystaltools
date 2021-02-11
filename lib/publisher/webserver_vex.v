module publisher

import os
import nedpals.vex.router
import nedpals.vex.server
import nedpals.vex.ctx
import nedpals.vex.utils
import myconfig
import json

// this webserver is used for looking at the builded results

struct MyContext {
	config &myconfig.ConfigRoot
	// now you can inject other stuff also
}

enum FileType {
	unknown
	wiki
	file
	image
	html
}

struct ErrorJson {
pub:
	site_errors []SiteError
	page_errors map[string][]PageError
}

fn print_req_info(mut req ctx.Req, mut res ctx.Resp) {
	println('$utils.red_log() $req.method $req.path')
}

fn helloworld(req &ctx.Req, mut res ctx.Resp) {
	mut myconfig := (&MyContext(req.ctx)).config
	res.send('Hello World! $myconfig.paths.base', 200)
}


fn path_wiki_get(mut config myconfig.ConfigRoot, site string, name string) ?(FileType, string) {
	// println(" - wiki get: '$site' '$name'")
	site_config := config.site_wiki_get(site)?
	mut name2 := name.to_lower().trim(' ').trim(".").trim(' ')
	mut path2 := ''
	extension := os.file_ext(name2).trim('.')
	mut sitename := site_config.alias
	if sitename.starts_with('wiki_') || sitename.starts_with('info_') {
		sitename = sitename[5..]
	}

	if name.starts_with('file__') || name.starts_with('page__') || name.starts_with('html__') {
		splitted := name.split('__')
		if splitted.len != 3 {
			return error('filename not well formatted. Needs to have 3 parts. Now $name2 .')
		}
		name2 = splitted[2]
		if sitename != splitted[1] {
			return error('Sitename in name should correspond to ${sitename}. Now $name2 .')
		}
	}

	// println( " - ${app.req.url}")
	if name2.trim(" ")==""{
		name2="index.html"
	}else{
		name2 = name_fix_keepext(name2)
	}


	mut filetype := FileType{}
	if name2.starts_with('file__') {
		// app.set_content_type('text/html')
		filetype = FileType.file
	} else if name2.starts_with('page__') {
		filetype = FileType.wiki
	} else if name2.starts_with('html__') {
		filetype = FileType.html
	} else if name2.ends_with('.html') {
		filetype = FileType.html
	} else if name2.ends_with('.md') {
		filetype = FileType.wiki
	} else if extension == "" {
		filetype = FileType.wiki		
	} else {
		// consider all to be files (images)
		filetype = FileType.file
	}

	if filetype == FileType.wiki{
		if ! name2.ends_with(".md"){
			name2 += ".md"
		}
	}

	if name2 == '_sidebar.md' {
		name2 = 'sidebar.md'
	}

	if name2 == '_navbar.md' {
		name2 = 'navbar.md'
	}

	path2 = os.join_path(config.paths.publish, "wiki_"+sitename, name2)

	if name2 == 'readme.md' && (!os.exists(path2)) {
		name2 = 'sidebar.md'
		path2 = os.join_path(config.paths.publish, "wiki_"+sitename, name2)
	}

	// println('  > get: $path2 ($name)')

	if !os.exists(path2) {
		return error('cannot find file in: $path2')
	}

	return filetype, path2
}

fn index_template(wikis []string) string{
	return $tmpl('index_root.html')
}
fn error_template(sitename string, path string) string{
	err_file := os.read_file(path) or {
			return "ERROR: could not find errors file on $path"
		}
	errors := json.decode(ErrorJson, err_file) or {
			return "ERROR: json not well formatted on $path"
		}
	mut site_errors := errors.site_errors
	mut page_errors := errors.page_errors	
	return $tmpl('errors.html')
}

// Index (List of wikis) -- reads index.html
fn index_root(req &ctx.Req, mut res ctx.Resp) {
	config := (&MyContext(req.ctx)).config
	mut wikis := []string{}
	path := os.join_path(config.paths.publish)
	list := os.ls(path) or { panic(err) }
	for item in list {
		wikis << item
	}
	res.headers['Content-Type'] = ['text/html']
	res.send(index_template(wikis), 200)
}

fn return_wiki_errors(sitename string, req &ctx.Req, mut res ctx.Resp) {
	config := (&MyContext(req.ctx)).config
	path := os.join_path(config.paths.publish, "wiki_$sitename", "errors.json")
	t := error_template(sitename,path)
	if t.starts_with("ERROR:") { 
			res.send(t, 501) 
			return
		}
	// println(t)
	res.send(t, 200)
}

fn site_wiki_deliver(mut config myconfig.ConfigRoot, site string, path string, req &ctx.Req, mut res ctx.Resp) {
	name := os.base(path)
	if path.ends_with("errors") || path.ends_with("error") {
		return_wiki_errors(site,req,mut res)
		return
	}
	filetype, path2 := path_wiki_get(mut config,site,name) or { 
		println("could not get path for: $site:$name\n$err")
		res.send("$err", 404) 
		return
		}
	println(" - '$site:$name' -> $path2")
	if filetype == FileType.wiki{
		content := os.read_file(path2) or {res.send("Cannot find file: $path2\n$err", 404) return}
		res.send(content, 200)
	}else{
		if ! os.exists(path2){
			println(" - ERROR: cannot find path:$path2")
			res.send("cannot find path:$path2", 404) 
			return
		}else{
			// println("deliver: '$path2'")
			content := os.read_file(path2) or {res.send("Cannot find file: $path2\n$err", 404) return}
			//NOT GOOD NEEDS TO BE NOT LIKE THIS: TODO: find way how to send file
			res.send(content, 200)
			// res.send_file(path2,200)
		}
	}
}

fn site_www_deliver(mut config myconfig.ConfigRoot, site string, path string, req &ctx.Req, mut res ctx.Resp) {
	mut site_path := config.path_publish_web_get(site)or {res.send("Cannot find site: $site\n$err", 404) return}
	mut path2 := path
	if path2.trim("/")==""{
		path2="index.html"
		res.headers['Content-Type'] = ['text/html']
	}
	path2 = os.join_path(site_path,path2)
	if ! os.exists(path2){
		println(" - ERROR: cannot find path:$path2")
		res.send("cannot find path:$path2", 404) 
		return
	}else{
		// println("deliver: '$path2'")
		content := os.read_file(path2) or {res.send("Cannot find file: $path2\n$err", 404) return}
		//NOT GOOD NEEDS TO BE NOT LIKE THIS: TODO: find way how to send file
		println(path2)
		if path2.ends_with(".css"){
			res.headers['Content-Type'] = ['text/css']
		}
		if path2.ends_with(".js"){
			res.headers['Content-Type'] = ['text/javascript']
		}

		res.send(content, 200)
	}
}

fn site_deliver(req &ctx.Req, mut res ctx.Resp) {
	mut config := (&MyContext(req.ctx)).config
	mut path := req.params["path"]
	splitted := path.trim("/").split("/")
	mut site := splitted[0].to_lower()
	path = splitted[1..].join("/").trim("/").trim(" ")

	if site.starts_with("www_"){
		site = site[4..]
		site_www_deliver(mut config,site,path,req,mut res)		
	}else if site.starts_with("wiki_"){
		site = site[5..]
		site_wiki_deliver(mut config,site,path,req,mut res)		
	}else{
		//if no wiki or www used then its a website
		site_www_deliver(mut config,site,path,req,mut res)
	}
}


// Run server
pub fn webserver_run() {
	mut app := router.new()

	config := myconfig.get()
	mycontext := &MyContext{
		config: &config
	}
	app.inject(mycontext)

	app.use(print_req_info)

	app.route(.get, '/', index_root)
	app.route(.get, '/hello', helloworld)
    app.route(.get, '/*path',site_deliver)


	server.serve(app, 9998)
}

