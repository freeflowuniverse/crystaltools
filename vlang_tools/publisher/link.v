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
	image
	unknown
	html
	data
}

enum LinkState {
	init
	ok
	notfound
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
	isimage bool
	isexternal bool
mut:
	state LinkState
}

fn (link Link) error_msg_get() string {
	mut msg := ''
	if link.state == LinkState.notfound {
		if link.isimage {
			msg = 'Cannot find image: $link.link'
		} else {
			msg = 'Cannot find link: $link.link'
		}
	}
	return msg
}

fn ( link Link) link_original_get() string {
	mut original := ""
	if link.isimage{
		original = "![${link.name}](${link.link})"
	}else{
		original = "[${link.name}](${link.link})"
	}
	return original
}


//////////////////////////////// REWRITE LINKS SOURCE

fn ( link Link) link_source_clean_get() string {	
	linkclean := name_fix(link.link.trim(" "))
	nameclean := link.name.trim(" ")
	mut clean := ""
	if link.isimage{
		clean = "![$nameclean]($linkclean)"
	}else{
		clean = "[$nameclean]($linkclean)"
	}
	return clean
}

//walk over text and replace links to proper names & links for the source file
pub fn ( parseresult ParseResult) source_links_fix(content string) string {
	println(parseresult.links)
	mut tosearch := ""
	mut toreplace := ""
	mut content2 := content
	for link in parseresult.links{
		tosearch = link.link_original_get()
		toreplace = link.link_source_clean_get()
		println("replace: $tosearch to $toreplace")
		content2=content2.replace(tosearch,toreplace)
	}
	return content2
}

//////////////////////////////// REWRITE LINKS SERVER

//rewrite the link on how it needs to be on the server
fn ( link Link) link_mdserver_clean_get(publisher &Publisher) ?string {	
	nameclean := link.name.trim(" ")
	linkclean := name_fix(link.link.trim(" "))	
	mut clean := "" //the result
	errors := []PageError{}

	//only when local we need to check if we can find files/pages or not
	if !link.isexternal{
		if link.cat == LinkType.page{
			linkclean = os.file_name(linkclean)
			if !publisher.page_exists(linkclean) {
				return error( "- ERROR: CANNOT FIND LINK: '$linkclean' for ${link.name.trim()}")
			}

		} else link.cat != LinkType.unknown {
			// println("found image link:$linkstr")
			linkclean = os.file_name(linkclean)
			if !publisher.image_exists(linkclean) {
				return error("- ERROR: CANNOT FIND FILE: '$linkclean' for ${link.name.trim()}")
			}else{
				//remember that the image has been used
				_, mut img := publisher.image_get(linkstr) or {panic("bug")}
				if !(page.name in img.usedby){
					img.usedby<<page.name
				}
			}
		}

		if ! linkstr.contains("__"){
			//only do when on local server
			if link.cat == LinkType.page {
				linkstr = 'page__${site.name}__$linkstr'
			}else{
				//works for image and other files
				linkstr = 'file__${site.name}__$linkstr'
			}
		}


	} 


	if link.isimage{
		clean = "!"
	clean += "[$nameclean](image__$sitename__$itemname)"
	return clean
}

//replace the markdown docs on the server
pub fn ( parseresult ParseResult) mdserver_links_fix(content string, publisher &Publisher ) string {
	println(parseresult.links)
	mut tosearch := ""
	mut toreplace := ""
	mut content2 := content
	for link in parseresult.links{
		tosearch = link.link_original_get()
		toreplace = link.link_mdserver_clean_get() //get how link needs to be on the md server
		println("replace server: $tosearch to $toreplace")
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
	mut linkcat := LinkType.unknown
	mut isimage := false
	mut isexternal := false
	mut ext := ""
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
						isimage = true //will remember this is an image (can be external or internal)
					}
					state = ParseStatus.linkopen
				}
				// check for the end of the link/image
			} else if state == ParseStatus.link {
				// original += char
				if char == ')' {
					// end of capture group
					// see if its an external link or internal
					mut linkstate := LinkState.init
					if capturegroup_post.contains('://') {
						linkstate = LinkState.ok
						isexternal = true
					}
					
					//check which link type
					ext = os.file_ext(os.base(capturegroup_post)).to_lower()
					if ext[1..] in ["jpg","png","svg","jpeg","gif"]{
						linkcat = LinkType.image
					}else if ext[1..] in ["md"]{
						linkcat = LinkType.page
					}else if ext[1..] in ["html"]{
						linkcat = LinkType.html							
					}else if (! capturegroup_post.contains_any("./?&;")) && ! isexternal{
						linkcat = LinkType.page
					}else if ext[1..] in ["doc","docx","zip","xls","pdf","xlsx","ppt","pptx"]{
						linkcat = LinkType.file		
					}else if ext[1..] in ["json","yaml","yml","toml"]{
						linkcat = LinkType.data											
					}else{
						linkcat = LinkType.unknown
					}
					
					parseresult.links << Link{
						name: capturegroup_pre
						link: capturegroup_post
						cat: linkcat
						state: linkstate
						isimage: isimage
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
	// println("")
	return parseresult
}
