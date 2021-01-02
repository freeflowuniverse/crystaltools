module builder

import regex

pub struct IPAddress {
	addr string
	port int		
	pub:
		cat  IpAddressType = IpAddressType.ipv4
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
		ip :=IPAddress{addr: addr_string.trim_space()}
		return ip
	}		
}

// get the right name depending the platform type
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
