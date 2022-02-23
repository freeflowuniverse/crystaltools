module main

import digitaltwin
import redisclient

fn test_anotehr() {
	mut redis := redisclient.get_local()

	println('[+] loading local digital twin')
	mut twin := digitaltwin.factory(42) or { panic(err) }

	println('[+] loading (fake) foreign digital twin')

	mut sk := []byte{}
	sk = twin.signkey.verify_key.public_key[0..32]

	mut foreign := digitaltwin.foreign(sk) or { panic(err) }

	data := 'Hello World'

	println('[+] encoding and signing message: $data')
	payload := twin.sign(data)
	println(payload)

	twin.verify(payload)

	println('[+] checking foreign message')
	valid, message := foreign.verify(payload)
	if valid {
		println('SIGNATURE VALID')
		println(message)
	} else {
		println('INVALID SIGNATURE')
	}

	digitaltwin.bootstrap_test_populate(mut &redis)
}
