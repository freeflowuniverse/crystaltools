module main
// import os

import nedpals.vex.router
import nedpals.vex.server
import nedpals.vex.ctx

import myconfig
import json



fn print_req_info(mut req ctx.Req, mut res ctx.Resp) {
	println('${req.method} ${req.path}')
}


fn helloworld (req &ctx.Req, mut res ctx.Resp) {
		//I NEED THIS config to be available here, we cannot fetch it for each request thats too inefficient
		//are there globals? or ways how to do this?
		res.send('Hello World!', 200)
	}

// Run server
pub fn webserver_run() {	
    mut app := router.new()
	mut config :=	myconfig.get()
	app.inject(config)

    app.use(print_req_info)

	app.route(.get, '/hello',helloworld )	

    server.serve(app, 6789)	

}

fn main(){
	webserver_run()
}

