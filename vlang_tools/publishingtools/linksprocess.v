module publishingtools

enum ParseStatus {
	start
	linkopen
	link
	imageopen
	image
	comment
}

enum LinkType {
	image
	link
}

enum LinkState {
	init
	ok
	notfound
	external
}

struct ParseResult {
mut:
	links []Link
}

struct Link {
	name  string
	link  string
	cat   LinkType
mut:
	dest  string // proper formatted destiny of link
	state LinkState
}

pub fn (mut link Link) error_msg_get() string {
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

// will replace the links to be correct (see if they exist in the known sites, )
pub fn (mut link Link) check_replace(lines string, mut pt PublTools, mut site Site, originSite string) string {
	if link.state == LinkState.external {
		// no need to process are external links
		return lines
	}
	// if not empty, we have already processed this so can return right away
	if link.dest != '' {
		return lines
	}
	mut lines_out := ''
	mut new_text := ''
	mut original_text := '[$link.name]($link.link)'
	mut linkstr := '' // will be the clean destination
	// support for links like ./img/zero_db.png, needs to become $site:zero_db.png
	if '/' in link.link {
		splitted := link.link.split('/')
		linkstr = splitted.pop() // is that always latest???
	} else {
		linkstr = link.link
	}
	linkstr = linkstr.trim(' ')
	linkstr = linkstr.trim('.')
	if !(':' in linkstr) {
		linkstr = '$site.name:$linkstr'
	}

	mut new_link := ""
	
	if originSite == site.name{
		new_link = linkstr.split(":")[1]
	}else{
		splitted := linkstr.split(":")
		sitename := splitted[0]
		item := splitted[1]
		new_link = "/$sitename/$item"
		if link.cat == LinkType.image{
			domain := pt.domain
			new_link = "$domain$new_link"
		}
	}

	new_text = ''
	if link.state == LinkState.init {
		// need to check if link exists
		link.state = LinkState.ok
		if link.cat == LinkType.link {
			if !pt.page_exists(linkstr) {
				link.state = LinkState.notfound
				new_text = "[ERROR: CANNOT FIND LINK: '$linkstr' for ${link.name.trim("
				')}]($linkstr)'
			}
		} else {
			if !pt.image_exists(linkstr) {
				link.state = LinkState.notfound
				new_text = "[ERROR: CANNOT FIND IMAGE: '$linkstr' for ${link.name.trim("
				')}]($linkstr)'
			}
		}
	}
	new_text = '[${link.name.trim(' ')}]($new_link)'
	if link.cat == LinkType.image {
		// add the ! to be a link
		new_text = '!$new_text'
		original_text = '!$original_text'
	}
	lines_out = lines.replace(original_text, new_text)
	link.dest = new_link // so now we know the proper destination string, TODO: check it does not happen multiple times
	return lines_out
}

// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT RELIALITIES
pub fn link_parser(text string) ParseResult {
	mut charprev := ''
	mut char := ''
	mut state := ParseStatus.start
	mut capturegroup_pre := '' // is in the []
	mut capturegroup_post := '' // is in the ()
	mut parseresult := ParseResult{}
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
					} else {
						state = ParseStatus.linkopen
					}
				}
				// check for the end of the link/image
			} else if state == ParseStatus.image || state == ParseStatus.link {
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
						}
					} else {
						parseresult.links << Link{
							name: capturegroup_pre
							link: capturegroup_post
							cat: LinkType.link
							state: linkstate
						}
					}
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
