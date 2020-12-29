module vredis2

import net
// import strconv
import io
// import time



struct Redis {
	pub mut:
		socket net.TcpConn
		reader io.BufferedReader
}

struct SetOpts {
	pub mut:
		ex       int=-4
		px       int=-4
		nx       bool
		xx       bool
		keep_ttl bool
}

enum KeyType {	
	t_none
	t_string
	t_list
	t_set
	t_zset
	t_hash
	t_stream
	t_unknown
}


// https://redis.io/topics/protocol
pub fn connect(addr string) ?Redis {
	mut socket := net.dial_tcp(addr)?
	return Redis{
			socket: &socket, 
			reader: io.new_buffered_reader({reader: io.make_reader(&socket)})
		}
}

// fn (mut  r Redis) read() ?[]byte {
// 	mut data := []byte{len: 1024}
// 	r.reader.read(mut data)?
// 	return data
// }

fn (mut r Redis) socket_read_line() ?string {
	mut res := r.reader.read_line() or {
			if err=="" {
				return error("no data in socket readline")
			}else{}
				return error("other error in readline: '$err'")
			}
	println("readline result:'$res'")
	// reader.close() //IS THERE NO CLOSE WE NEED TO DO, NO MEMLEAK?
	return res
}

fn (mut r Redis) socket_write_line(data string) ? {
	r.socket.write('$data\r\n'.bytes())?
}

fn (mut r Redis) socket_write(data string) ?string {
	r.socket.write(data.bytes())
}

pub fn (mut r Redis) disconnect() {
	r.socket.close() or { }
}

//implement protocol of redis how to send he data
// https://redis.io/topics/protocol
fn (mut r Redis) encode_send(items []string)?{
	mut out := "*${items.len}\r\n"
	for item in items{
		out+="\$${item.len}\r\n$item\r\n"
	}
	//for debug purposes
	println("redisdata:${out.replace("\n","\\n").replace("\r","\\r")}")
	r.socket_write(out)
}


enum ReceiveState {data error array}

//send command to redis, expects to have an OK back
pub fn (mut r Redis) send_ok(items []string)?{
	mut a:=r.send(items)?
	if a[0]!="OK"{
		return error("did not get ok result from server for cmd $items")
	}
}

//return the int or string as string, if empty return then empty string
pub fn (mut r Redis) send(items []string)? []string {
	r.encode_send(items)?
	mut result := []string{}
	mut state := ReceiveState.data //we don't know so we consider it to be data
	mut array_nritems := 0
	mut array_nritems_done := 0
	mut bulkstring_size := 0
	mut line := ""

	// a := io.read_all(reader: r.socket) or {panic(err)}
	// println(a.bytestr())
	// panic("debug")


	for i in 0..100{

		if i>98{
			panic ("should not get here, means I was not getting out of readline loop")
		}

		//keep on reading untill no more data, hope this works
		line = r.socket_read_line()?

		if line.starts_with("+OK"){
			return ["OK"]
		}

		if line.starts_with("-"){
			//error coming back from redis server
			return error(line[1..])
		}

		if state == ReceiveState.array {
			array_nritems_done ++
			if array_nritems_done > array_nritems{
				panic ("means more items than they should be in the return of redis")
			}else if array_nritems_done == array_nritems{
				//processed all
				break			
			}else{
				result << line
			}
		}

		//meaningfull data, now need to process
		if line.starts_with(":"){
			//integer, don't see how to do else than put as string
			result << line[1..]
		}else if line.starts_with("+"){			
			//default string
			result << line[1..]
		}else if line.starts_with("$"){
			println("bulkstr_start:'${line[1..]}'")
			if line[1..]=="-1" {
				//represents null
				return none //will give error with empty string
			}
			//read next line
			bulkstring_size = line[1..].int()
			println("read next line, to complete the bulkstr")
			line = r.socket_read_line()?
			println("bulkstr:'$line'")
			if line.len != bulkstring_size{
				panic ("error in bulkstr")
			}
			result << line
		}else if line.starts_with("*"){
			if state == ReceiveState.array{
				panic ("do not support nested arrays yet")
			}
			state = ReceiveState.array
			array_nritems = line[1..].int()
			array_nritems_done = 0
			continue
		}
		
		if state != ReceiveState.array{			
			//means we did not find anything further to do, or it was single result or list
			//if array we should not get here because means there are still more elements to process
			break
		}

	}
	if result.len ==0 {	panic("did not find result in data, should be always something")}
	return result
}


// fn parse_int(res string) ?int {
// 	sval := res[1..res.len - 2]
// 	return strconv.atoi(sval)
// }

// fn parse_float(res string) ?f64 {
// 	return strconv.atof64(res)
// }

