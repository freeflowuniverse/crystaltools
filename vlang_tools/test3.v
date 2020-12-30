import vredis2

fn redis_server() {
	l := vredis2.listen("0.0.0.0", 5555) or { panic(err) }
	for {
		conn := l.socket.accept() or { continue }
		go vredis2.newclient(conn)
	}
}

redis_server()
