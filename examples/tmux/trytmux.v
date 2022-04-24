	
module main
import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.process
import time

fn do()?{

	mut n:=builder.node_local()?

	mut t:=n.tmux
	t.stop()?
	
	t.window_new(name:"test1",cmd:"mcs",reset:true)?
	t.window_new(name:"test2",cmd:"mc",reset:true)?

	// t.sessions["main"].windows["test1"].delete()?
	t.scan()?
	t.list_print()

	for _ in 0 .. 100 {
		//will only get process info once every 5 sec, otherwise will return from mem
		pm := process.processmap_get()?
		// println(pm)
		time.sleep(time.Duration(1000000000))
		println(pm)
	}
	


}

fn main() {
	do() or {panic(err)}
}

