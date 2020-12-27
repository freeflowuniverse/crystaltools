module manifestor


//test the creation of a node
fn test_node_local_basic1() {

	n := node_get({})
	res := n.execute("ls /")
	println(res)

	panic("SSS")

}



//test the creation of a node
fn test_node_ssh_basic1() {

	n := node_get({ipaddr:IPAddress{addr:"127.0.0.1",port:9001}})


}