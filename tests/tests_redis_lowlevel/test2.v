module main

import redisclient

fn main() {
	mut redis := redisclient.get_local()

	println(redis)
}
