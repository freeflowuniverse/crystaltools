	
module main
import despiegk.crystallib.tmux
import despiegk.crystallib.process
import time

fn do()?{

	mut t:=tmux.new(name:"testtmux")?
	// t.stop()?
	
	t.window_new(name:"test1",cmd:"mcs",reset:true)?
	t.window_new(name:"test2",cmd:"mc",reset:true)?

	// t.sessions["main"].windows["test1"].delete()?
	t.scan()?
	t.list_print()

	for _ in 0 .. 100 {
		pm := process.processmap_get()?
		println(pm)
		time.sleep(time.Duration(1000000000))
	}
	


}

fn main() {
	do() or {panic(err)}
}

