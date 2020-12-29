import vredis2
mut redis := vredis2.connect('localhost:6379') or { panic(err) }
redis.set('test', 'some data')
r := redis.get_string('test') or {
	panic('>>>>> err: $err | errcode: $errcode')
}
eprintln('--------------------------------')
eprintln(r)
eprintln('--------------------------------')
