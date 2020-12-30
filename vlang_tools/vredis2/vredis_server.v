module vredis2

import net

struct RedisSrv {
	pub mut:
		socket net.TcpListener
}

type RedisCallback = fn(int, int) string

struct RedisHandler {
	command string
	handler RedisCallback
}

// https://redis.io/topics/protocol
pub fn listen(addr string, port int) ?RedisSrv {
	mut socket := net.listen_tcp(port)?
	// socket.set_read_timeout(2 * time.second)
	return RedisSrv{
		socket: socket
	}
}

pub fn command_ping(a int, b int) string {
	return (a + b).str()
}

pub fn newclient(conn net.TcpConn)? {
	mut h := []RedisHandler{}
	h << RedisHandler{command: "PING", handler: command_ping}

	// create a client on the existing socket
	mut client := Redis{socket: conn}

	println(h)

	for {
		// fetch command from client (process incoming buffer)
		value := client.get_response()?
		print(value)
	}
}

