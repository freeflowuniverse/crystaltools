fn test() ?string {
	return ''
}

// assert test()==""
// shouldn't next be impossible, what is design?
// its not a string or not an error, should not compile in my opinion
fn test2() ?string {
	return none
}

// this is ofcourse ok
fn test3() ?string {
	return error('this is an error')
}

fn main() {
	test3() or { println('test3 ok') }
	test2() or { panic("should not get here I guess. Error is empty anyhow '$err'") }
}
