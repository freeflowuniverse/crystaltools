import io
import net
import time
import strings

const (
	test_port = 22334
)

fn setup() (net.TcpListener, net.TcpConn, net.TcpConn) {
	server := net.listen_tcp(server_port) or {
		panic(err)
	}
	mut socket := server.accept() or {
		panic(err)
	}
	return server, socket
}

// server, socket := setup()
// mut reader := io.new_buffered_reader({
// 	reader: io.make_reader(client)
// })

fn handle_conn(_c net.TcpConn) {
	mut c := _c
	for {
		mut buf := []byte{len: 100, init: 0}
		read := c.read(mut buf) or {
			println('Server: connection dropped')
			return
		}
		c.write(buf[..read]) or {
			println('Server: connection dropped')
			return
		}
	}
}


// fn echo_server(l net.TcpListener) ? {
fn echo_server() ? {	
	l := net.listen_tcp(test_port) or {
		panic(err)
	}
	for {
		new_conn := l.accept() or {
			continue
		}
		go handle_conn(new_conn) //thread per user
	}
	return none
}

fn sender() ? {
	mut c := net.dial_tcp('127.0.0.1:$test_port')?
	defer {
		println("close sender")
		c.close() or { }
	}
	towait := 0.0
	for i in 0..100 {
		towait = i/50
		time.sleep(towait)

		data := 'Hello from vlib/net!\n'
		c.write_str(data)?
	mut buf := []byte{len: 4096}
	read := c.read(mut buf)?
	assert read == data.len
	for i := 0; i < read; i++ {
		assert buf[i] == data[i]
	}
	println('Got "$buf.bytestr()"')
	return none
}


fn echo() ? {
	mut c := net.dial_tcp('127.0.0.1:$test_port')?
	defer {
		c.close() or { }
	}
	data := 'Hello from vlib/net!'
	c.write_str(data)?
	mut buf := []byte{len: 4096}
	read := c.read(mut buf)?
	assert read == data.len
	for i := 0; i < read; i++ {
		assert buf[i] == data[i]
	}
	println('Got "$buf.bytestr()"')
	return none
}


go echo_server(l)
time.sleep(0.1)
go sender()

//now call the server
echo() or {
	panic(err)
}
l.close() or { }
