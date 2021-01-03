import publisher

fn test_link1() {

	r1 := publisher.link_parser(" ![ some text    ]( http://something.com/?hi&yo  )")
	println(r1)

	panic("a")


}