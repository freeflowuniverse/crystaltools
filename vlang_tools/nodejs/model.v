module nodejs

pub struct NodejsConfig {
pub mut:
	version NodejsVersion
	path    string
}

struct NodejsVersion {
pub mut:
	name string
	cat     NodejsVersionEnum
}

pub enum NodejsVersionEnum {
	lts
	latest
}



