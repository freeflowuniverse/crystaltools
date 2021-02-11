module texttools

import regex

struct ReplaceInstructions {
pub mut:
	instructions []ReplaceInstruction
}

struct ReplaceInstruction {
pub:
	regex_str    string
	find_str     string
	replace_with string
pub mut:
	regex regex.RE
}

// regex string see https://github.com/vlang/v/blob/master/vlib/regex/README.md
// find_str is a normal search (text)
// replace is the string we want to replace the match with
fn (mut self ReplaceInstructions) add(regex_find_str string, replace_with string) ? {
	mut item := regex_find_str
	if item.starts_with('^R') {
		item = item[2..] // remove ^r
		r := regex.regex_opt(item) or { return error(err) }
		self.instructions << ReplaceInstruction{
			regex_str: item
			regex: r
			replace_with: replace_with
		}
	} else {
		self.instructions << ReplaceInstruction{
			replace_with: replace_with
			find_str: item
		}
	}
}

// does the matching line per line
// will use dedent function, on text
fn (mut self ReplaceInstructions) replace(text string) ?string {
	mut gi := 0
	mut text2 := dedent(text)
	mut line2 := ''
	mut res := []string{}
	// println('AAA\n$text\nBBB\n')
	for line in text2.split_into_lines() {
		line2 = line
		for mut i in self.instructions {
			// if i.find_str == '' {
			// 	println(i.regex.get_query())
			// }
			if i.find_str == '' {
				// all := i.regex.find_all(text2)
				// for gi < all.len {
				// 	println(i.regex.get_query() + ' RESULT:')
				// 	println('${text2[all[gi]..all[gi + 1]]}')
				// 	gi += 2
				// }
				line2 = i.regex.replace(line2, i.replace_with)
				// q := i.regex.get_query()
				// println('REPLACE_R:$q:$line:$line2')
			} else {
				line2 = line2.replace(i.find_str, i.replace_with)
				// println('REPLACE:$i.find_str:$line:$line2')
			}
		}
		res << line2
	}
	// println('AAA2\n$text2\nBBB2\n')
	return res.join('\n')
}

//
// input is ["^Rregex:replacewith",...]
// input is ["^Rregex:^Rregex2:replacewith"]
// input is ["findstr:findstr:replacewith"]
// input is ["findstr:^Rregex2:replacewith"]
// findstr is a normal string to look for, is always matched case insensitive
// regex is regex as described in https://github.com/vlang/v/blob/master/vlib/regex/README.md
//   regex start with ^R
// all matching is case insensitive
fn regex_instructions_new(replacelist []string) ?ReplaceInstructions {
	mut ri := ReplaceInstructions{}
	for i in replacelist {
		splitted := i.split(':')
		replace_with := splitted[splitted.len - 1]
		// last one not to be used
		if splitted.len < 2 {
			return error('Cannot add $i because needs to have 2 parts, wrong syntax, to regex instructions')
		}
		for item in splitted[0..(splitted.len - 1)] {
			ri.add(item, replace_with) ?
		}
	}
	return ri
}
