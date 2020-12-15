# regex 

more info see https://modules.vlang.io/regex.html

```vlang
import regex 

query := r'\[.*\]\( *\w*\:*\w+ *\)'

text := "
[ an s. s! ]( wi4ki:something )
[ an s. s! ](wiki:something)
[ an s. s! ](something)dd
d [ an s. s! ](something ) d
[  more text ]( something )  [ something b ](something)dd

"

// mut re := regex.regex_opt(query) or { panic(err) }

mut re := regex.new()
re.compile_opt(query) or { println(err) }

for line in text.split_into_lines() {
  start, end := re.match_string(line)
  if start>0{
    println(text[start..end])
    // println(line)
  }

}
```