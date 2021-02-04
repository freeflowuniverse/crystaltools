module nodejs

pub struct NpmConfig {
pub mut:
	version NpmVersion
	path    string
}

struct NpmVersion {
pub mut:
	version string
	cat     NpmVersionEnum
}

pub enum NpmVersionEnum {
	lts
	latest
}



