module texttools

fn test_regex1() {
	text := '

	this is test_1 SomeTest
	this is test 1 SomeTest

	need to replace TF to ThreeFold
	need to replace ThreeFold0 to ThreeFold
	need to replace ThreeFold1 to ThreeFold

	'

	text_out := '

	this is TTT SomeTest
	this is TTT SomeTest

	need to replace ThreeFold to ThreeFold
	need to replace ThreeFold to ThreeFold
	need to replace ThreeFold to ThreeFold

	'

	mut ri := regex_instructions_new([' TF : ThreeFold0 :^R ThreeFold1 : ThreeFold ']) or {
		panic(err)
	}
	ri.add('^Rtest[ _]1', 'TTT') or { panic(err) }
	mut text_out2 := ri.replace(text) or { panic(err) }

	// println('!' + dedent(text) + '!')
	// println('!' + dedent(text_out) + '!')
	// println('!' + dedent(text_out2) + '!')

	assert dedent(text_out2).trim('\n') == dedent(text_out).trim('\n')
	// panic('s')
}
