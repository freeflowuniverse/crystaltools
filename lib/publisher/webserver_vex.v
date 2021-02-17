module publishermod

import os
import nedpals.vex.router
import nedpals.vex.server
import nedpals.vex.ctx
import nedpals.vex.utils
import myconfig
import json

// this webserver is used for looking at the builded results

struct MyContext {
	config    &myconfig.ConfigRoot
	publisher &Publisher
}

enum FileType {
	unknown
	wiki
	file
	image
	html
}

fn print_req_info(mut req ctx.Req, mut res ctx.Resp) {
	println(utils.red_log('req.method $req.path'))
}

fn helloworld(req &ctx.Req, mut res ctx.Resp) {
	mut myconfig := (&MyContext(req.ctx)).config
	res.send('Hello World! $myconfig.paths.base', 200)
}

fn path_wiki_get(mut config myconfig.ConfigRoot, sitename string, name string) ?(FileType, string) {
	filetype, mut name2 := filetype_name_get(mut config, sitename, name) ?
	mut path2 := os.join_path(config.paths.publish, sitename.replace("info_", "wiki_"), name2)

	if name2 == 'readme.md' && (!os.exists(path2)) {
		name2 = 'sidebar.md'
		path2 = os.join_path(config.paths.publish, sitename, name2)
	}
	// println('  > get: $path2 ($name)')

	if !os.exists(path2) {
		return error('cannot find file in: $path2')
	}

	return filetype, path2
}

fn filetype_name_get(mut config myconfig.ConfigRoot, site string, name string) ?(FileType, string) {
	// println(" - wiki get: '$site' '$name'")
	site_config := config.site_wiki_get(site) ?
	mut name2 := name.to_lower().trim(' ').trim('.').trim(' ')
	// mut path2 := ''
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
	if name2.trim(' ') == '' {
		name2 = 'index.html'
	} else {
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
	} else if extension == '' {
		filetype = FileType.wiki
	} else {
		// consider all to be files (images)
		filetype = FileType.file
	}

	if filetype == FileType.wiki {
		if !name2.ends_with('.md') {
			name2 += '.md'
		}
	}

	if name2 == '_sidebar.md' {
		name2 = 'sidebar.md'
	}

	if name2 == '_navbar.md' {
		name2 = 'navbar.md'
	}

	return filetype, name2
}

fn index_template(wikis map[string][]string, sites map[string][]string, port int) string {
	mut port_str := ""
	if port != 80{
		port_str = ":$port"
	}
	return $tmpl('index_root.html')
}

fn error_template(req &ctx.Req, sitename string) string {
	config := (&MyContext(req.ctx)).config
	mut publisherobj := (&MyContext(req.ctx)).publisher
	mut errors := PublisherErrors{}
	mut site := publisherobj.site_get(sitename) or {
		return 'cannot get site, in template for errors\n $err'
	}
	if publisherobj.develop {
		errors = publisherobj.errors_get(site) or {
			return 'ERROR: cannot get errors, in template for errors\n $err'
		}
	} else {
		path2 := os.join_path(config.paths.publish, 'wiki_$sitename', 'errors.json')
		err_file := os.read_file(path2) or { return 'ERROR: could not find errors file on $path2' }
		errors = json.decode(PublisherErrors, err_file) or {
			return 'ERROR: json not well formatted on $path2'
		}
	}
	mut site_errors := errors.site_errors
	mut page_errors := errors.page_errors.clone()
	return $tmpl('errors.html')
}

// Index (List of wikis) -- reads index.html
fn index_root(req &ctx.Req, mut res ctx.Resp) {
	config := (&MyContext(req.ctx)).config
	mut publisherobj := (&MyContext(req.ctx)).publisher
	mut wikis := map[string][]string{}
	mut sites := map[string][]string{}

	mut all := map[string][]string{}
	for site in config.sites{
		all[site.name.replace("info_", "wiki_")] = site.domains
	}
	
	if publisherobj.develop {
		publisherobj.check()
		for site in publisherobj.sites {
			wikis[site.config.name] = all[site.config.name]
		}
	} else {
		path := os.join_path(config.paths.publish)
		list := os.ls(path) or { panic(err) }
		for item in list {
			if item.starts_with("wiki_"){
				wikis[item] = all[item]
			}else if item.starts_with("www_"){
				sites[item] = all[item]
			}
		}
	}
	res.headers['Content-Type'] = ['text/html']
	res.send(index_template(wikis, sites, config.port), 200)
}

fn return_wiki_errors(sitename string, req &ctx.Req, mut res ctx.Resp) {
	t := error_template(req, sitename)
	if t.starts_with('ERROR:') {
		res.send(t, 501)
		return
	}
	// println(t)
	res.send(t, 200)
}

fn site_wiki_deliver(mut config myconfig.ConfigRoot, domain string, path string, req &ctx.Req, mut res ctx.Resp) ? {
	mut sitename := config.publish_web_get_name(domain)or {res.send("Cannot find domain: $domain\n$err", 404) return}
	name := os.base(path)
	mut publisherobj := (&MyContext(req.ctx)).publisher
	if path.ends_with('errors') || path.ends_with('error') || path.ends_with('errors.md')
		|| path.ends_with('error.md') {
		return_wiki_errors(sitename, req, mut res)
		return
	}

	if publisherobj.develop {
		filetype, name2 := filetype_name_get(mut config, sitename, name) ?
		mut site2 := publisherobj.site_get(sitename) or {
			res.send('Cannot find site: $sitename\n$err', 404)
			return
		}
		if name2 == 'index.html' {
			// mut index := os.read_file( site.path + '/index.html') or {
			// 	res.send("index.html not found", 404) 
			// }
			index_out := template_wiki_root(sitename, '')
			// index_root(req, mut res)
			res.send(index_out, 200)
			return
		} else if filetype == FileType.wiki {
			mut page := site2.page_get(name2, mut publisherobj) ?
			content4 := page.content_defs_replaced(mut publisherobj) ?
			res.send(content4, 200)
			return
		} else {
			// now is a file
			file3 := site2.file_get(name2, mut publisherobj) ?
			path3 := file3.path_get(mut publisherobj)
			content3 := os.read_file(path3) or {
				res.send('Cannot find file: $path3\n$err', 404)
				return
			}
			// NOT GOOD NEEDS TO BE NOT LIKE THIS: TODO: find way how to send file
			res.send(content3, 200)
		}
	} else {
		filetype, path2 := path_wiki_get(mut config, sitename, name) or {
			println('could not get path for: $sitename:$name\n$err')
			res.send('$err', 404)
			return
		}
		println(" - '$sitename:$name' -> $path2")
		if filetype == FileType.wiki {
			content := os.read_file(path2) or {
				res.send('Cannot find file: $path2\n$err', 404)
				return
			}
			res.headers['Content-Type'] = ['text/html']
			res.send(content, 200)
		} else {
			if !os.exists(path2) {
				println(' - ERROR: cannot find path:$path2')
				res.send('cannot find path:$path2', 404)
				return
			} else {
				// println("deliver: '$path2'")
				content := os.read_file(path2) or {
					res.send('Cannot find file: $path2\n$err', 404)
					return
				}
				// NOT GOOD NEEDS TO BE NOT LIKE THIS: TODO: find way how to send file
				res.send(content, 200)
				// res.send_file(path2,200)
			}
		}
	}
}

fn content_type_get(path string) ?string {
	if path.ends_with('.css') {
		return 'text/css'
	}
	if path.ends_with('.js') {
		return 'text/javascript'
	}
	if path.ends_with('.svg') {
		return 'image/svg+xml'
	}
	if path.ends_with('.png') {
		return 'image/png'
	}
	if path.ends_with('.jpeg') || path.ends_with('.jpg') {
		return 'image/jpg'
	}
	if path.ends_with('.gif') {
		return 'image/gif'
	}
	return error('cannot find content type for $path')
}
fn site_www_deliver(mut config myconfig.ConfigRoot, domain string, path string, req &ctx.Req, mut res ctx.Resp)? {
	mut site_path := config.path_publish_web_get_domain(domain)or {res.send("Cannot find domain: $domain\n$err", 404) return}
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
		if os.is_dir(path2){
			path2 = os.join_path(path2, "index.html")
			res.headers['Content-Type'] = ['text/html']
		}
		// println("deliver: '$path2'")
		content := os.read_file(path2) or {res.send("Cannot find file: $path2\n$err", 404) return}
		//NOT GOOD NEEDS TO BE NOT LIKE THIS: TODO: find way how to send file
		if path2.ends_with(".css"){
			res.headers['Content-Type'] = ['text/css']
		}
		if path2.ends_with(".js"){
			res.headers['Content-Type'] = ['text/javascript']
		}
		if path2.ends_with(".svg"){
			res.headers['Content-Type'] = ['image/svg+xml']
		}
		if path2.ends_with(".png"){
			res.headers['Content-Type'] = ['image/png']
		}
		if path2.ends_with(".jpg"){
			res.headers['Content-Type'] = ['image/jpg']
		}
		if path2.ends_with(".jpeg"){
			res.headers['Content-Type'] = ['image/jpeg']
		}
		if path2.ends_with(".gif"){
			res.headers['Content-Type'] = ['image/gif']
		}


		res.send(content, 200)
	}
}


fn site_deliver(req &ctx.Req, mut res ctx.Resp) {
	mut config := (&MyContext(req.ctx)).config
	mut path := req.params['path']
	splitted := path.trim('/').split('/')
	path = splitted[0..].join('/').trim('/').trim(' ')
	mut publisherobj := (&MyContext(req.ctx)).publisher
	
	if ! ('Host' in req.headers){
		panic('Host Header is required')
	}

	if req.headers['Host'].len == 0{
		panic('Host is missing')
	}

	mut host := req.headers['Host'][0]
	mut splitted2 := host.split(":")
	mut domain := splitted2[0]

	if domain == "localhost"{
		index_root(req, mut res)
		return
	}

	mut iswiki := true

	mut domainfound := false
	for siteconfig in config.sites{
		if domain in siteconfig.domains{
			domainfound = true
			if siteconfig.cat == myconfig.SiteCat.web{
				iswiki = false
			}
			break
		}
	}

	if !domainfound{
		res.send('unknown domain $domain', 404)
			return
	}


	if !iswiki {
		if publisherobj.develop {
			res.send('websites cannot be shown in development mode', 404)
			return
		}
		site_www_deliver(mut config, domain, path, req, mut res) or {
			res.send('unknown error.\n$err', 501)
			return
		}
	} else if iswiki {
		site_wiki_deliver(mut config, domain, path, req, mut res) or {
			res.send('unknown error.\n$err', 501)
			return
		}
	}
}

// Run server
pub fn webserver_run(publisher &Publisher) {
	mut app := router.new()

	config := myconfig.get()
	mycontext := &MyContext{
		config: &config
		publisher: publisher
	}
	app.inject(mycontext)

	app.use(print_req_info)
    app.route(.get, '/*path',site_deliver)

	server.serve(app, 9998)
}
