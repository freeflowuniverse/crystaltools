	
	
module main
import despiegk.crystallib.builder
// import os


fn do()?{

	reset := true

	mut app1 := builder.node_get(ipaddr:"46.101.149.252",name:"app1",debug:true,reset:reset)?
	mut app2 := builder.node_get(ipaddr:"178.62.204.160",name:"app2",debug:true,reset:reset)?
	mut home := builder.node_get(ipaddr:"192.168.10.254",name:"home",debug:true,reset:reset)?

	app1.node_install_docker_swarm()?
	app2.node_install_docker_swarm_add(app1)?
	home.node_install_docker_swarm_add(app1)?

	//now we have a swarm cluster operational



}

fn main() {
	do() or {panic(err)}
}

