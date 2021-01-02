module builder

import regex

pub struct IPAddress {
	pub:
		addr string
		port int	
		cat  IpAddressType = IpAddressType.ipv4
}

pub enum IpAddressType {
	ipv4
	ipv6
}


pub fn ipaddress_new(addr_string string) ?IPAddress{
	mut cat := IpAddressType.ipv4
	mut addr := addr_string
	mut port := "0"

	if "::" in addr_string && addr_string.count("::") == 1{
		cat = IpAddressType.ipv6
		s := addr_string.split("::")
		addr, port = s[0], s[1]
	} else if ":" in addr_string && addr_string.count(":") == 1{
		cat = IpAddressType.ipv4
		s := addr_string.split(":")
		addr, port = s[0], s[1]
	} else if ":" in addr_string && addr_string.count(":") > 1{
		cat = IpAddressType.ipv6
	} else if "." in addr_string && addr_string.count(".") == 3{
		cat = IpAddressType.ipv4
	}else{
		return error("Invalid Ip address string")
	}
	
	mut ip := IPAddress{
		addr: addr.trim_space()
		port: port.int()
		cat: cat
	}

	ip.check()

	return ip
}

pub fn (mut ipaddr IPAddress) ping(executor Executor) bool{
	if ipaddr.cat == IpAddressType.ipv4{
		executor.exec('ping -c 3 $ipaddr.addr') or {return false}
	}else{
		executor.exec('ping -6 -c 3 $ipaddr.addr') or {return false}
	}
	return true
}

// check if ipaddress is well formed
pub fn (mut ipaddr IPAddress) check() bool {
	mut query := r''
	if ipaddr.cat == IpAddressType.ipv4{
		query = r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
	}else{
		query = r'(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))'
	}
	mut re := regex.regex_opt(query) or { panic(err) }

	start, _ := re.match_string(ipaddr.addr)

	if start < 0 {
		return false
	} else {
		return true
	} 
}

fn (mut ipaddr IPAddress) address() string {
	return '$ipaddr.addr:$ipaddr.port'
}
