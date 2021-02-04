module myconfig
import nodejs

import os

pub fn base_path_get() string {
	return '$os.home_dir()/.publisher'
}

pub fn code_path_get() string {
	return '$os.home_dir()/codesync'
}

pub fn nodejs_config() NodejsConfig {
	mut c := NodejsConfig{
		version: NodejsVersion{
			cat: NodejsVersionEnum.lts
		}
	}
	return c
}


pub fn nodejs_path_get() string {
	mut c := nodejs_config()
	return c.path
}


pub fn site_config() SiteConfigs {
	mut sc := SiteConfigs{}
	sc.sites << SiteConfig{
		name: 'info_tftech'
		url: 'https://github.com/threefoldtech/info_tftech'
	}
	sc.sites << SiteConfig{
		name: 'www_threefold_cloud'
		url: 'https://github.com/threefoldfoundation/www_threefold_cloud'
		cat: SiteCat.web
	}
	sc.sites << SiteConfig{
		name: 'www_threefold_farming'
		url: 'https://github.com/threefoldfoundation/www_threefold_farming'
		cat: SiteCat.web
	}
	sc.sites << SiteConfig{
		name: 'www_threefold_twin'
		url: 'https://github.com/threefoldfoundation/www_threefold_twin'
		cat: SiteCat.web
	}
	sc.sites << SiteConfig{
		name: 'www_threefold_marketplace'
		url: 'https://github.com/threefoldfoundation/www_threefold_marketplace'
		cat: SiteCat.web
	}
	sc.sites << SiteConfig{
		name: 'www_conscious_internet'
		url: 'https://github.com/threefoldfoundation/www_conscious_internet'
		cat: SiteCat.web
	}
	sc.sites << SiteConfig{
		name: 'www_threefold_tech'
		url: 'https://github.com/threefoldtech/www_threefold_tech'
		cat: SiteCat.web
	}
	sc.sites << SiteConfig{
		name: 'www_examplesite'
		url: 'https://github.com/threefoldfoundation/www_examplesite'
		cat: SiteCat.web
	}
	sc.sites << SiteConfig{
		name: 'info_foundation'
		url: 'https://github.com/threefoldfoundation/info_foundation'
	}
	sc.sites << SiteConfig{
		name: 'info_tfgrid_sdk'
		url: 'https://github.com/threefoldfoundation/info_tfgrid_sdk'
	}
	sc.sites << SiteConfig{
		name: 'info_legal'
		url: 'https://github.com/threefoldfoundation/info_legal'
	}
	sc.sites << SiteConfig{
		name: 'info_cloud'
		url: 'https://github.com/threefoldfoundation/info_cloud'
	}
	sc.sites << SiteConfig{
		name: 'data_threefold'
		url: 'https://github.com/threefoldfoundation/data_threefold'
		cat: SiteCat.data
	}
	return sc
}
