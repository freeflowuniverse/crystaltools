module builder

pub struct IPAddress {
	addr string
	port int		
	pub:
		cat  IpAddressType
}

pub enum IpAddressType {
	ipv4
	ipv6
}

//ask for IPAddress 
// format '192.168.3.3:33' or  '192.168.3.3'
// TODO: for ipv6
pub fn ipaddress_new(addr_string string) ?IPAddress{
	if ":" in addr_string {
		splitted:=addr_string.split(":")
		if splitted.len==2 {
			addr := splitted[0].trim_space()
			port := splitted[1].int() 
			ip:=IPAddress{addr:addr ,port:port}
			return ip
		}else{
			return error("cannot parse ipaddr: needs to be of form '192.168.3.3:33' or  '192.168.3.3'")
		}
	}else{
		ip:=IPAddress{addr: addr_string.trim_space()}
		return ip
	}		
}

// get the right name depending the platform type
pub fn (mut ipaddr IPAddress) ping(executor Executor) {
	// TODO: implement using ping over executor, support 4 & 6
}

// check if ipaddress is well formed
fn (mut ipaddr IPAddress) check() ? {
	// TODO: check if well formed
}

fn (mut ipaddr IPAddress) address() string {
	return '$ipaddr.addr:$ipaddr.port'
}
