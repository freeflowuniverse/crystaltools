import vredis2

fn redis_server() {
	println("Listening")

	l := vredis2.listen("0.0.0.0", 5555) or { panic(err) }
	for {
		conn := l.socket.accept() or { continue }
		go vredis2.new_client(conn)
	}
}

redis_server()
