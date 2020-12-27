module manifestor
// hello_test.v
fn test_ping() {
	mut addr := IPAddress{
		addr: "127.0.0.1",
		port: 9001,
		cat: IpAddressType.ipv4,
	}

	addr.ping(ExecutorLocal{})
}