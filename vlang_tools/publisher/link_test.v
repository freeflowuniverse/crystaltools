import publisher

fn test_link1() {

	r1 := publlisher.link_parser(" ![ some text    ]( http://something.com/?hi&yo  )")
	println(r1)

	panic("a")


}