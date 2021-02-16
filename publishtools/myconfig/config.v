module myconfig

import os
import gittools

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

pub fn myconfig_get() ?ConfigRoot {
	mut conf := get()
	mut gt := gittools.new(conf.paths.code) or { return error('ERROR: cannot load gittools:$err') }
	for mut site in conf.sites {
		if site.path_code == '' {
			// println(' < $site.reponame() ')
			mut repo := gt.repo_get(name: site.reponame()) or {
				// return error('ERROR: cannot find repo: $site.name\n$err')
				// do NOTHING, just ignore the site to work with
				// print(err)
				println(' - WARNING: ignore site: $site.name, $err')
				continue
			}
			site.path_code = repo.path_get()
		}
	}
	return conf
}
