module myconfig

import os

pub fn get() ConfigRoot {
	mut c := ConfigRoot{}
	c.paths.base = '$os.home_dir()/.publisher'
	c.paths.publish = '$c.paths.base/publish'
	c.paths.code = '$os.home_dir()/codewww'
	mut nodejsconfig := NodejsConfig{
		version: NodejsVersion{
			cat: NodejsVersionEnum.lts
		}
	}
	c.nodejs = nodejsconfig

	c.reset = false
	c.pull = false
	c.debug = true

	c.redis = false

	c.init()

	// add the site configurations to it
	site_config(mut &c)

	return c
}


