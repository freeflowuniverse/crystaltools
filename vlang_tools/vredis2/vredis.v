module vredis2


pub fn (mut r Redis) set(key string, value string)? {
	r.send_ok(['SET', key, value])?
}

pub fn (mut r Redis) get_int(key string) ?int {
	mut key2 := key.trim("\"'")
	res := r.send(['GET', key2])?
	return res[0].int()
}

pub fn (mut r Redis) get_string(key string) ?string {
	mut key2 := key.trim("\"'")
	res := r.send(['GET', key2])?
	return res[0]
}

// pub fn (mut r Redis) get(key string) string {
// 	message := 'GET "$key"\r\n'
// 	r.write(message) or {panic("cannot write message to redis")}
// 	res := r.socket_read_line() or {panic("cannot resd message from redis")}
// 	println(res)
// 	len := parse_int(res) or {panic("cannot parse int")}
// 	// if len == -1 {
// 	// 	return error('key not found')
// 	// }
// 	// return r.socket_read_line()
// 	return ""
// }



// pub fn (mut r Redis) incrby(key string, increment int) ?int {
// 	message := 'INCRBY "$key" $increment\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	rerr := parse_err(res)
// 	if rerr != '' {
// 		return error(rerr)
// 	}
// 	count := parse_int(res)
// 	return count
// }

// pub fn (mut r Redis) incr(key string) ?int {
// 	res := r.incrby(key, 1) or {
// 		return error(err)
// 	}
// 	return res
// }

// pub fn (mut r Redis) decr(key string) ?int {
// 	res := r.incrby(key, -1) or {
// 		return error(err)
// 	}
// 	return res
// }

// pub fn (mut r Redis) decrby(key string, decrement int) ?int {
// 	res := r.incrby(key, -decrement) or {
// 		return error(err)
// 	}
// 	return res
// }

// pub fn (mut r Redis) incrbyfloat(key string, increment f64) ?f64 {
// 	message := 'INCRBYFLOAT "$key" $increment\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	rerr := parse_err(r.socket_read_line() or {return error(err)})
// 	if rerr != '' {
// 		return error(rerr)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	count := parse_float(res)
// 	return count
// }

// pub fn (mut r Redis) append(key string, value string) ?int {
// 	message := 'APPEND "$key" "$value"\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	count := parse_int(r.socket_read_line() or {return error(err)})
// 	return count
// }

// pub fn (mut r Redis) setrange(key string, offset int, value string) ?int {
// 	message := 'SETRANGE "$key" $offset "$value"\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	count := parse_int(r.socket_read_line() or {return error(err)})
// 	return count
// }

// pub fn (mut r Redis) lpush(key string, element string) ?int {
// 	message := 'LPUSH "$key" "$element"\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	count := parse_int(r.socket_read_line() or {return error(err)})
// 	return count
// }

// pub fn (mut r Redis) rpush(key string, element string) ?int {
// 	message := 'RPUSH "$key" "$element"\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	count := parse_int(r.socket_read_line() or {return error(err)})
// 	return count
// }

// pub fn (mut r Redis) expire(key string, seconds int) ?int {
// 	message := 'EXPIRE "$key" $seconds\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	count := parse_int(res)
// 	return count
// }

// pub fn (mut r Redis) pexpire(key string, millis int) ?int {
// 	message := 'PEXPIRE "$key" $millis\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	count := parse_int(res)
// 	return count
// }

// pub fn (mut r Redis) expireat(key string, timestamp int) ?int {
// 	message := 'EXPIREAT "$key" $timestamp\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	count := parse_int(res)
// 	return count
// }

// pub fn (mut r Redis) pexpireat(key string, millistimestamp i64) ?int {
// 	message := 'PEXPIREAT "$key" $millistimestamp\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	count := parse_int(res)
// 	return count
// }

// pub fn (mut r Redis) persist(key string) ?int {
// 	message := 'PERSIST "$key"\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	count := parse_int(res)
// 	return count
// }


// pub fn (mut r Redis) getset(key string, value string) ?string {
// 	message := 'GETSET "$key" $value\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	len := parse_int(res)
// 	if len == -1 {
// 		return ''
// 	}
// 	return r.socket_read_line() or {return error(err)}[0..len]
// }

// pub fn (mut r Redis) getrange(key string, start int, end int) ?string {
// 	message := 'GETRANGE "$key" $start $end\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	len := parse_int(res)
// 	if len == 0 {
// 		r.socket_read_line() or {return error(err)}
// 		return ''
// 	}
// 	return r.socket_read_line() or {return error(err)}[0..len]
// }

// pub fn (mut r Redis) randomkey() ?string {
// 	message := 'RANDOMKEY\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	len := parse_int(res)
// 	if len == -1 {
// 		return error('database is empty')
// 	}
// 	return r.socket_read_line() or {return error(err)}[0..len]
// }

// pub fn (mut r Redis) strlen(key string) ?int {
// 	message := 'STRLEN "$key"\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	count := parse_int(res)
// 	return count
// }

// pub fn (mut r Redis) lpop(key string) ?string {
// 	message := 'LPOP "$key"\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	len := parse_int(res)
// 	if len == -1 {
// 		return error('key not found')
// 	}
// 	return r.socket_read_line() or {return error(err)}[0..len]
// }

// pub fn (mut r Redis) rpop(key string) ?string {
// 	message := 'RPOP "$key"\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	len := parse_int(res)
// 	if len == -1 {
// 		return error('key not found')
// 	}
// 	return r.socket_read_line() or {return error(err)}[0..len]
// }

// pub fn (mut r Redis) llen(key string) ?int {
// 	message := 'LLEN "$key"\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	rerr := parse_err(res)
// 	if rerr != '' {
// 		return error(rerr)
// 	}
// 	count := parse_int(res)
// 	return count
// }

// pub fn (mut r Redis) ttl(key string) ?int {
// 	message := 'TTL "$key"\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	count := parse_int(res)
// 	return count
// }

// pub fn (mut r Redis) pttl(key string) ?int {
// 	message := 'PTTL "$key"\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	count := parse_int(res)
// 	return count
// }

// pub fn (mut r Redis) exists(key string) ?int {
// 	message := 'EXISTS "$key"\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	count := parse_int(res)
// 	return count
// }

// pub fn (mut r Redis) del(key string) ?int {
// 	message := 'DEL "$key"\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	count := parse_int(res)
// 	return count
// }

// pub fn (mut r Redis) rename(key string, newkey string) bool {
// 	message := 'RENAME "$key" "$newkey"\r\n'
// 	r.write(message) or {
// 		return false
// 	}
// 	res := r.socket_read_line() or {return error(err)}[0..3]
// 	match res {
// 		'+OK' {
// 			return true
// 		}
// 		else {
// 			return false
// 		}
// 	}
// }

// pub fn (mut r Redis) renamenx(key string, newkey string) ?int {
// 	message := 'RENAMENX "$key" "$newkey"\r\n'
// 	r.write(message) or {
// 		return error(err)
// 	}
// 	res := r.socket_read_line() or {return error(err)}
// 	rerr := parse_err(res)
// 	if rerr != '' {
// 		return error(rerr)
// 	}
// 	count := parse_int(res)
// 	return count
// }

// pub fn (mut r Redis) flushall() bool {
// 	message := 'FLUSHALL\r\n'
// 	r.write(message) or {
// 		return false
// 	}
// 	res := r.socket_read_line() or {return error(err)}[0..3]
// 	match res {
// 		'+OK' {
// 			return true
// 		}
// 		else {
// 			return false
// 		}
// 	}
// }
