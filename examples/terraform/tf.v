module main

// import despiegk.crystallib.fftools
// import despiegk.crystallib.git3
import despiegk.crystallib.terraform
import threefoldtech.vgrid.explorer
import threefoldtech.vgrid.gridproxy

const sshkey='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/9RNGKRjHvViunSOXhBF7EumrWvmqAAVJSrfGdLaVasgaYK6tkTRDzpZNplh3Tk1aowneXnZffygzIIZ82FWQYBo04IBWwFDOsCawjVbuAfcd9ZslYEYB3QnxV6ogQ4rvXnJ7IHgm3E3SZvt2l45WIyFn6ZKuFifK1aXhZkxHIPf31q68R2idJ764EsfqXfaf3q8H3u4G0NjfWmdPm9nwf/RJDZO+KYFLQ9wXeqRn6u/mRx+u7UD+Uo0xgjRQk1m8V+KuLAmqAosFdlAq0pBO8lEBpSebYdvRWxpM0QSdNrYQcMLVRX7IehizyTt+5sYYbp6f11WWcxLx0QDsUZ/J'

fn do()? {

	//get link to terraform factory (allows you to deploy anything on TFGrid)
	//if terraform client not install will do it automatically
	mut tf := terraform.get()?

	
	// make sure the following env is set  TFGRID_MNEMONIC, is your private key
	// can also set: TFGRID_SSHKEY as env variable, or specify as in this example
	//select wich network you want to use, .test or .main or.dev
	mut d := tf.deployment_get(
			name:"test",
			sshkey:sshkey,
			tfgridnet:.test
		)?

	
	mut vm1 := d.vm_ubuntu_add(
			name:"kds1",
			nodeid:14,
			memory: 8000,
			public_ip: true
			)

	mut vm2 := d.vm_ubuntu_add(
			name:"kds2",
			nodeid:14,
			memory: 8000,
			public_ip: true
			)

	//add disk of 10GB mounted on root for vm2
	vm2.disk_add(10,"/root")

	//lets first destroy before we deploy, so there are no leftovers
	//if you don't destroy will try to match what was already deployed
	d.destroy()?
	//lets deploy our solution
	d.deploy()?

	//print how vm2 looks like
	println(vm2)

	// mut node := vm2.sshnode_get()?

}

fn do2()? {

	mut explorer := explorer.get(.test)
	mut gridproxy := gridproxy.get(.test)
	
	//TO MAKE SURE CACHE IS EMPTY DO FOLLOWING
	// explorer.cache_drop_all()?

	// mut r := explorer.twin_list()?
	mut r := explorer.nodes_list()?
	println(r)
	println(r.len)

	ni := gridproxy.node_info(16)?
	println(ni)

}

fn main() {
	//main loop, just call our main method & panic if issues
	do2() or {panic(err)}
}
