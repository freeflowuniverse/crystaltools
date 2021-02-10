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

fn site_config(mut c ConfigRoot) {
	c.sites << SiteConfig{
		name: 'www_threefold_cloud'
		url: 'https://github.com/threefoldfoundation/www_threefold_cloud'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_threefold_farming'
		url: 'https://github.com/threefoldfoundation/www_threefold_farming'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_threefold_twin'
		url: 'https://github.com/threefoldfoundation/www_threefold_twin'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_threefold_marketplace'
		url: 'https://github.com/threefoldfoundation/www_threefold_marketplace'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_conscious_internet'
		url: 'https://github.com/threefoldfoundation/www_conscious_internet'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_threefold_tech'
		url: 'https://github.com/threefoldtech/www_threefold_tech'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_examplesite'
		url: 'https://github.com/threefoldfoundation/www_examplesite'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'info_foundation'
		url: 'https://github.com/threefoldfoundation/info_foundation'
	}
	c.sites << SiteConfig{
		name: 'info_tfgrid_sdk'
		alias: 'manual'
		url: 'https://github.com/threefoldfoundation/info_tfgrid_sdk'
	}
	c.sites << SiteConfig{
		name: 'info_legal'
		url: 'https://github.com/threefoldfoundation/info_legal'
	}
	c.sites << SiteConfig{
		name: 'info_cloud'
		url: 'https://github.com/threefoldfoundation/info_cloud'
	}
	c.sites << SiteConfig{
		name: 'info_tftech'
		url: 'https://github.com/threefoldtech/info_tftech'
	}
	c.sites << SiteConfig{
		name: 'info_digitaltwin'
		url: 'https://github.com/threefoldfoundation/info_digitaltwin.git'
	}
	c.sites << SiteConfig{
		name: 'data_threefold'
		url: 'https://github.com/threefoldfoundation/data_threefold'
		cat: SiteCat.data
	}
}
