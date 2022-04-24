	
	
module main
import freeflowuniverse.crystallib.builder
// import os


fn do()?{

	reset := false

	//app1 will be the master
	mut app1 := builder.node_new(ipaddr:"46.101.149.252",name:"app1",debug:true,reset:reset)?
	mut app2 := builder.node_new(ipaddr:"178.62.204.160",name:"app2",debug:true,reset:reset)?
	mut home := builder.node_new(ipaddr:"192.168.10.254",name:"home",debug:true,reset:reset)?

	app1.node_install_docker_swarm(reset:reset)?
	app2.node_install_docker_swarm_add(mut master:app1)?
	home.node_install_docker_swarm_add(mut master:app1)?

	//will also install the portainer agents on the other 2 nodes
	app1.install_portainer()?

	//now we have a swarm cluster operational



}

fn main() {
	do() or {panic(err)}
}

