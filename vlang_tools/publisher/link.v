module publisher

import os

enum ParseStatus {
	start
	linkopen
	link
	comment
}

enum LinkType {
	file	
	page
	unknown
	html
	data
	missing
	email
}

enum LinkState {
	init
	ok
	error
}

struct ParseResult {
pub mut:
	links []Link
}

struct Link {
	// original string //how link was put in the document
	name  string  //has the spaces inside, so we can replace
	cat   LinkType
	isfile bool
	isexternal bool
	pub:
		link  string  //has the spaces inside

// mut:
// 	state LinkState
}

fn ( link Link) link_original_get() string {
	mut original := ""
	if link.isfile{
		original = "![${link.name}](${link.link})"
	}else{
		original = "[${link.name}](${link.link})"
	}
	return original
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
	mut linkcat := LinkType.unknown
	mut isfile := false
	mut isexternal := false
	mut ext := ""
	// mut original := ""
	// no need to process files which are not at least 2 chars
	if text.len > 2 {
		charprev = ''
		for i in 0 .. text.len {
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
				// check for end in link or file			
			} else if state == ParseStatus.linkopen {
				// original += char
				if charprev == ']' {
					// end of capture group
					// next char needs to be ( otherwise ignore the capturing
					if char == '(' {
						if state == ParseStatus.linkopen {
							// remove the last 2 chars: ](  not needed in the capturegroup
							state = ParseStatus.link
							capturegroup_pre = capturegroup_pre[0..capturegroup_pre.len - 1]
						} else {
							state = ParseStatus.start
							capturegroup_pre = ''
						}
					} else {
						// cleanup was wrong match, was not file nor link
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
						linkcat = LinkType.file
						isfile = true //will remember this is an file (can be external or internal)
					}
					state = ParseStatus.linkopen
				}
				// check for the end of the link/file
			} else if state == ParseStatus.link {
				// original += char
				if char == ')' {
					// end of capture group
					// see if its an external link or internal
					//mut linkstate := LinkState.init
					if capturegroup_post.contains('://') {
						// linkstate = LinkState.ok
						isexternal = true
					}
					
					//check which link type
					ext = os.file_ext(os.base(capturegroup_post)).to_lower()
					
					splitted := capturegroup_post.split(" ")
					if splitted.len > 0 && splitted[0].ends_with(".html"){
						linkcat = LinkType.html
					}else if capturegroup_post.starts_with("mailto:"){
						linkcat = LinkType.email
					}else if ext == "."{
						linkcat = LinkType.missing
					}else if ext != "" {
							if ext[1..] in ["jpg","png","svg","jpeg","gif"]{
								linkcat = LinkType.file
							}else if ext[1..] in ["md"]{
								linkcat = LinkType.page
							}else if ext[1..] in ["html"]{
								linkcat = LinkType.html	
							}else if ext[1..] in ["doc","docx","zip","xls","pdf","xlsx","ppt","pptx"]{
								linkcat = LinkType.file		
							}else if ext[1..] in ["json","yaml","yml","toml"]{
								linkcat = LinkType.data											
							}else if (! capturegroup_post.contains_any("./?&;")) && ! isexternal{
								linkcat = LinkType.page
							}
						
					}else  {
						
						linkcat = LinkType.unknown
					}
					
					parseresult.links << Link{
						name: capturegroup_pre.trim(" ")
						link: capturegroup_post.trim(" ")
						cat: linkcat
						// state: linkstate
						isfile: isfile
						isexternal: isexternal
						// original: original
					}
					// original = ""
					capturegroup_pre = ''
					capturegroup_post = ''
					state = ParseStatus.start
					linkcat = LinkType.unknown //put back on unknown
				} else {
					capturegroup_post += char
				}
			}
			charprev = char // remember the previous one
			// println("$char $state '$capturegroup_pre|$capturegroup_post'")
		}
	}
	return parseresult
}
