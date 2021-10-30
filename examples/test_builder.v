	
	
module main
import despiegk.crystallib.builder
// import os


fn do()?{
	mut home := builder.node_get(ipaddr:"192.168.10.118")?

	home.executor.debug_on()

	// home.shell()?
	// println(home.db.environment)

	assert home.cmd_exists("mc")==true
	assert home.cmd_exists("cmdnotexist")==false

	assert home.done_exists("something")==false

	home.done_set("something2","testa")?
	g:= home.done_get("something2")?
	assert g=="testa"
	assert home.done_exists("something2")==true

	println("reset manually")

	//reset manually
	home.done = map[string]string{}
	home.done_load()?
	assert home.done_exists("something2")
	g2:= home.done_get("something2")?
	assert g2=="testa"


}

fn main() {
	do() or {panic(err)}
}

