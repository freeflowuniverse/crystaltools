module publisher

// import os

enum ParseStatus {
	start
	linkopen
	link
	imageopen
	image
	comment
}

enum LinkType {
	external //link to a http(s) resource not in the publisher server
	file	//file on the local publisher
	image	//image (jpg, jpeg, png, svg) on the local publisher
	page	//another markdown file
}

enum LinkState {
	init
	ok
	notfound
	external
	error
}

struct ParseResult {
mut:
	links []Link
}

struct Link {
	// original string //how link was put in the document
	name  string  //has the spaces inside, so we can replace
	link  string  //has the spaces inside
	cat   LinkType
mut:
	state LinkState
}

fn (link Link) error_msg_get() string {
	mut msg := ''
	if link.state == LinkState.notfound {
		if link.cat == LinkType.image {
			msg = 'Cannot find image: $link.link'
		} else {
			msg = 'Cannot find link: $link.link'
		}
	}
	return msg
}

fn ( link Link) link_original_get() string {
	mut original := ""
	if link.cat == LinkType.image{
		original = "![${link.name}](${link.link})"
	}else{
		original = "[${link.name}](${link.link})"
	}
	return original
}

fn ( link Link) link_clean_get() string {	
	linkclean := name_fix(link.link.trim(" "))
	nameclean := link.name.trim(" ")
	mut clean := ""
	if link.cat == LinkType.image{
		clean = "![$nameclean]($linkclean)"
	}else{
		clean = "[$nameclean]($linkclean)"
	}
	return clean
}


//walk over text and replace links to proper names & links
pub fn ( parseresult ParseResult) text_links_fix(content string) string {
	println(parseresult.links)
	mut tosearch := ""
	mut toreplace := ""
	mut content2 := content
	for link in parseresult.links{
		tosearch = link.link_original_get()
		toreplace = link.link_clean_get()
		println("replace: $tosearch to $toreplace")
		content2=content2.replace(tosearch,toreplace)
	}
	return content2
}

// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT REALITIES
// returns all the links
pub fn link_parser(text string) ParseResult {
	mut charprev := ''
	mut char := ''
	mut state := ParseStatus.start
	mut capturegroup_pre := '' // is in the []
	mut capturegroup_post := '' // is in the ()
	mut parseresult := ParseResult{}
	// mut original := ""
	// no need to process files which are not at least 2 chars
	if text.len > 2 {
		charprev = ''
		for i in 1 .. text.len {
			char = text[i..i + 1]
			// check for comments end
			if state == ParseStatus.comment {
				if text[i - 3..i] == '-->' {
					state = ParseStatus.start
					capturegroup_pre = ''
					capturegroup_post = ''
				}
				// check for comments start
			} else if i > 3 && text[i - 4..i] == '<!--' {
				state = ParseStatus.comment
				capturegroup_pre = ''
				capturegroup_post = ''
				// check for end in link or image			
			} else if state == ParseStatus.imageopen || state == ParseStatus.linkopen {
				// original += char
				if charprev == ']' {
					// end of capture group
					// next char needs to be ( otherwise ignore the capturing
					if char == '(' {
						if state == ParseStatus.imageopen {
							state = ParseStatus.image
							// remove the last 2 chars: ](  not needed in the capturegroup
							capturegroup_pre = capturegroup_pre[0..capturegroup_pre.len - 1]
						} else if state == ParseStatus.linkopen {
							state = ParseStatus.link
							capturegroup_pre = capturegroup_pre[0..capturegroup_pre.len - 1]
						} else {
							state = ParseStatus.start
							capturegroup_pre = ''
						}
					} else {
						// cleanup was wrong match, was not image nor link
						state = ParseStatus.start
						capturegroup_pre = ''
					}
				} else {
					capturegroup_pre += char
				}
				// is start, check to find links	
			} else if state == ParseStatus.start {
				if char == '[' {
					if charprev == '!' {
						state = ParseStatus.imageopen
						// original = "!["
					} else {
						state = ParseStatus.linkopen
						// original = "["
					}
				}
				// check for the end of the link/image
			} else if state == ParseStatus.image || state == ParseStatus.link {
				// original += char
				if char == ')' {
					// end of capture group
					// see if its an external link or internal
					mut linkstate := LinkState.init
					if capturegroup_post.contains('://') {
						linkstate = LinkState.external
					}
					if state == ParseStatus.image {
						parseresult.links << Link{
							name: capturegroup_pre
							link: capturegroup_post
							cat: LinkType.image
							state: linkstate
							// original: original
						}
					} else {
						parseresult.links << Link{
							name: capturegroup_pre
							link: capturegroup_post
							cat: LinkType.link
							state: linkstate
							// original: original
						}
					}
					// original = ""
					capturegroup_pre = ''
					capturegroup_post = ''
					state = ParseStatus.start
				} else {
					capturegroup_post += char
				}
			}
			charprev = char // remember the previous one
			// println("$char $state '$capturegroup_pre|$capturegroup_post'")
		}
	}
	// println("")
	return parseresult
}
