// import libp2p
// import net

// socket := net.dial_tcp("localhost:6378") or {
// 	panic( err)
// }

// println(socket)

import vredis2

mut redis := vredis2.connect("localhost:6379") or {
		panic(err)
	}

// redis.set("test","some data")
r := redis.get_string("test") or {panic(err)}
println(r)
