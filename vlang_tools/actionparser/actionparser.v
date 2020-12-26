module actionparser
import os

enum ParseBlockStatus {
	start 
	action 
}


enum ParseStatus {
	start 
	actionstart //found !! or #!! or //!!, now we need to find action name
	param_name //need to get params out
	param_value_quote //found ' need to find ending '
	param_valua_multiline //busy finding the multiline
	comment //found // or # at end
}

struct ParseResult {
mut:
	actions []ParseAction
}

struct ParseAction {
	name  string
	params []ParseParam
}

struct ParseParam {
	name string
	value string
}

//first step is to get the blocks out
struct Blocks {
	mut:
		blocks []Block
}

struct Block {
	mut:
		name string
		content string
}

// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT RELIALITIES

pub fn parse(path string) ?ParseResult {
	if ! os.exists(path){
		return error("path: '$path' does not exist, cannot parse.")
	}
	content := os.read_file(path) or {panic('Failed to load file $path')}

	blocks := parse_into_blocks(content) ?

	mut parseresult := ParseResult{}

	parseresult.parse_actions(blocks)

	return parseresult

}

//remove all leading spaces at same level
fn deintend(text string){
	mut pre:=999
	mut pre_current:=0
	mut line_strip:=""
	for line in text.split_into_lines(){
		line_strip = line
		line_strip = line_strip.replace("\t","    ")
		pre_current = line_strip.len-line_strip.trim_left().len
		if pre>pre_current{
			pre=pre_current
		}
	}

}

//each block is name of action and the full content behind
fn parse_into_blocks(text string) ?Blocks {
	mut state := ParseBlockStatus.start
	mut blocks := Blocks{}
	mut block := Block{}
	mut pos := 0
	mut line_strip := ""
	// no need to process files which are not at least 2 chars
	for line in text.split_into_lines() {
		// println("line: '$line'")
		line_strip = line.trim_space()
		if state == ParseBlockStatus.action {
			if line.starts_with(" ") || line.starts_with("\t") || line==""{
				//starts with tab or space, means block continues
				block.content += "\n"
				block.content += line
			} else{
				//means block stops
				state = ParseBlockStatus.start
				//add found block
				blocks.blocks << block
				block = Block{} //new block
			}
		}		
		if state == ParseBlockStatus.start {
			if line.starts_with("!!") || line.starts_with("#!!") || line.starts_with("//!!") {
				state = ParseBlockStatus.action
				pos = line.index(" ") or {0}
				if pos > 0 {
					block.name = line[0..pos]
					block.content = line[pos..]
				}else{
					block.name = line.trim_space() //means no arguments
				}
				block.name = block.name.trim_space().trim_left("#/!")
			}
			continue
		}
	}
	if block.name.len > 0 {
		//add last block to it
		blocks.blocks << block
	}
	println(blocks.blocks[13].content)
	panic("7")
	return blocks
}

fn (mut results ParseResult) parse_block(block Block){

	
}

fn (mut results ParseResult) parse_actions(blocks Blocks) {
	for block in blocks.blocks{
		results.parse_block(block)
	}
}
