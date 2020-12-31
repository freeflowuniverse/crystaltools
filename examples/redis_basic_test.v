import vredis2

fn redistest() ?bool {
	mut redis := vredis2.connect('localhost:6379') ?
	redis.set('test', 'some data') ?
	redis.set('hello', 'bla\r\nbli\r\nblu') ?
	mut r := redis.get('test') ?
	eprintln(r)
	r = redis.get('hello') ?
	eprintln(r)
	redis.set('counter', '0') ?
	mut i := redis.incrby('counter', 17) ?
	r = redis.get('counter') ?
	println(i)
	i = redis.incrby('counter', 10) ?
	println(i)
	i = redis.incr('counter') ?
	println(i)
	i = redis.decrby('counter', 5) ?
	println(i)
	i = redis.decr('counter') ?
	println(i)
	r = redis.get('counter') ?
	println(r)
	mut f := redis.incrbyfloat('counter', 1.42) ?
	println(f)
	i = redis.append('test', ', added') ?
	println(i)
	r = redis.get('test') ?
	println(r)
	i = redis.rpush('push', 'rpush') ?
	println(i)
	i = redis.lpush('push', 'lpush') ?
	println(i)
	r = redis.getset('test', 'newvalue') ?
	println(r)
	r = redis.get('test') ?
	println(r)
	r = redis.getrange('test', 1, 4) ?
	println(r)
	r = redis.getrange('nonexist', 0, 42) ?
	println(r)
	r = redis.randomkey() ?
	println(r)
	i = redis.strlen('test') ?
	println(i)
	// should fails wrong type
	i = redis.strlen('push') or { 0 }
	println(i)
	i = redis.llen('push') ?
	println(i)
	r = redis.lpop('push') ?
	println(r)
	r = redis.rpop('push') ?
	println(r)
	i = redis.ttl('push') ?
	println(i)
	// should be nil
	r = redis.rpop('push') or {
		if err == '(nil)' { true } else { false }
		''
	}
	i = redis.pttl('push') ?
	println(i)
	i = redis.del('push') ?
	println(i)
	i = redis.llen('push') ?
	println(i)
	// should fails
	i = redis.llen('counter') or { 0 }
	mut b := redis.rename('test', 'newtest') ?
	println(b)
	// array example support
	mut cursor, values := redis.scan(0) ?
	println(cursor)
	println(values)
	return true
}

fn main() {
	redistest() or { panic('err: $err | errcode: $errcode') }
}
