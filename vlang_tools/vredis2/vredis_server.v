module vredis2

import net
import time

struct RedisSrv {
	pub mut:
		socket net.TcpListener
}

type RedisCallback = fn(RedisValue) RedisValue

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


pub fn value_nil() RedisValue {
	return RedisValue{datatype: RedisValTypes.nil}
}

pub fn value_str(value string) RedisValue {
	return RedisValue{datatype: RedisValTypes.str, str: value}
}

pub fn value_success(value string) RedisValue {
	return RedisValue{datatype: RedisValTypes.success, str: value}
}

pub fn value_error(value string) RedisValue {
	return RedisValue{datatype: RedisValTypes.err, str: value}
}



pub fn command_ping(input RedisValue) RedisValue {
	if input.list.len > 1 {
		return value_success(input.list[1].str)
	}

	return value_success("PONG")
}

pub fn process_input(mut client Redis, value RedisValue) ?bool {
	mut h := []RedisHandler{}

	h << RedisHandler{command: "PING", handler: command_ping}

	command := value.list[0].str

	for rh in h {
		if command == rh.command {
			data := rh.handler(value)
			client.encode_send(data)
			return true
		}
	}

	err := value_error("Unknown command")
	client.encode_send(err)

	return false
}

pub fn new_client(conn net.TcpConn)? {
	// create a client on the existing socket
	mut client := Redis{socket: conn}

	for {
		// fetch command from client (process incoming buffer)
		value := client.get_response() or {
			if err == "no data in socket" {
				// FIXME
				time.sleep_ms(1)
			}
			continue
		}

		if value.datatype != RedisValTypes.list {
			// should not receive anything else than
			// array with commands and args
			println("Wrong request from client, rejecting")
			conn.close()
			return
		}

		if value.list[0].datatype != RedisValTypes.str {
			println("Wrong request from client, rejecting")
			conn.close()
			return
		}

		process_input(mut client, value)?
	}
}

