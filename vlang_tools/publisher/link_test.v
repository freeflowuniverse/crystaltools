import publisher

fn test_link1() {

	text:= " ![ some text    ]( http://something.com/?hi&yo  )"
	r1 := publisher.link_parser(text)
	println(r1)
	text2 := r1.text_links_fix(text)
	assert text2 ==  " ![some text](http://something.com/?hi&yo)"
}

fn test_link2() {

	text:= " ![ some text    ]( wiki.md  )"
	r1 := publisher.link_parser(text)
	println(r1)
	text2 := r1.text_links_fix(text)
	assert text2 ==  " ![some text](wiki.md)"

}


fn test_link3() {

	text:= " ![ some text    ]( test:wiki.md  )"
	r1 := publisher.link_parser(text)
	println(r1)
	text2 := r1.text_links_fix(text)
	assert text2 ==  " ![some text](test:wiki.md)"

}