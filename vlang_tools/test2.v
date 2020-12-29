
import io

import vredis2

mut redis := vredis2.connect("localhost:6379") or {
		panic(err)
	}

redis.set("test","some data")
r := redis.get_string("test") or {
	println("there is data in the readline, just can't read it")
	println("will now do a blocking read which times out and then will show the data")
	println("why does the readline not work???, and here it does?")
	println("other question: what to do to make timeout smaller")

	// redis.socket_read_line() or {panic("try once more")} //fails as well

	//the next will find the data, why is that?
	a := io.read_all(reader: redis.socket) or {panic(err)}
	println(a.bytestr())

	//panic the original error
	panic(err)
	}

println(r)
