module main

struct GitStructure {
pub mut:
	a int
	b string
}

fn init_codewww() GitStructure {
	mut gitstructure := GitStructure{}
	return gitstructure
}

const codecache = init_codewww()

pub fn get() &GitStructure {
	println('OBJ: $codecache')
	return &codecache
}

fn main() {
	mut r := get()
	r.a = 10
	println(r)

	mut r2 := get()
	println(r2)

	//shows that the a variable was remembered, which is what we needed

}

// output
// ```bash
// OBJ: GitStructure{
//     a: 0
//     b: ''
// }
// &GitStructure{
//     a: 10
//     b: ''
// }
// OBJ: GitStructure{
//     a: 10
//     b: ''
// }
// &GitStructure{
//     a: 10
//     b: ''
// }
// ```


