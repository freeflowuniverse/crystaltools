struct UserGen {
	name string
	age  int
}

// Note: T should be passed a struct name only
fn decode<T>(data string) T {
	mut result := T{}
	// compile-time `for` loop
	// T.fields gives an array of a field metadata type
	$for field in T.fields {
		$if field.typ is string {
			// $(string_expr) produces an identifier
			result.$(field.name) = data
		} $else $if field.typ is int {
			result.$(field.name) = 1
		}
	}
	return result
}

// println(@LINE)

println(decode<UserGen>('s'))

// `decode<UserGen>` generates:
// fn decode_UserGen(data string) UserGen {
//     mut result := UserGen{}
//     result.name = data
//     result.age = 1
//     return result
// }

// PRINTS:

// UserGen{
//     name: 's'
//     age: 1
// }
