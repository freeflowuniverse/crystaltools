import builder

fn main(){
	mut ip := builder.IPAddress{
		addr: "10.40.0.30"
	}

	assert ip.ping(builder.ExecutorLocal{}) == false
	ip = builder.IPAddress{
		addr: "8.8.8.8"
	}
	
	assert ip.ping(builder.ExecutorLocal{}) == true

	assert ip.check() == true
}