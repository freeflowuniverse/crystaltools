module myconfig

fn site_config(mut c ConfigRoot) {
	c.sites << SiteConfig{
		name: 'www_threefold_io'
		alias: 'tf'
		url: 'https://github.com/threefoldfoundation/www_threefold_io'
		cat: SiteCat.web
		domains: ['www.threefold.io', 'www.threefold.me']
	}
	c.sites << SiteConfig{
		name: 'www_threefold_cloud'
		alias: 'cloud'
		url: 'https://github.com/threefoldfoundation/www_threefold_cloud'
		cat: SiteCat.web
		domains: ['cloud.threefold.io', 'cloud.threefold.me']
	}
	c.sites << SiteConfig{
		name: 'www_threefold_farming'
		alias: 'farming'
		url: 'https://github.com/threefoldfoundation/www_threefold_farming'
		cat: SiteCat.web
		domains: ['farming.threefold.io', 'farming.threefold.me']
	}
	c.sites << SiteConfig{
		name: 'www_threefold_twin'
		alias: 'twin'
		url: 'https://github.com/threefoldfoundation/www_threefold_twin'
		cat: SiteCat.web
		domains: ['twin.threefold.io', 'twin.threefold.me']
	}
	c.sites << SiteConfig{
		name: 'www_threefold_marketplace'
		alias: 'marketplace'
		url: 'https://github.com/threefoldfoundation/www_threefold_marketplace'
		cat: SiteCat.web
		domains: ['now.threefold.io', 'marketplace.threefold.io', 'now.threefold.me', 'marketplace.threefold.me']
	}
	c.sites << SiteConfig{
		name: 'www_conscious_internet'
		alias: 'conscious_internet'
		url: 'https://github.com/threefoldfoundation/www_conscious_internet'
		cat: SiteCat.web
		domains: ['www.consciousinternet.org', 'eco.threefold.io', 'community.threefold.io', 'eco.threefold.me',
			'community.threefold.me',
		]
	}
	c.sites << SiteConfig{
		name: 'www_threefold_tech'
		alias: 'tech'
		url: 'https://github.com/threefoldtech/www_threefold_tech'
		cat: SiteCat.web
		domains: ['www.threefold.tech']
	}
	c.sites << SiteConfig{
		name: 'www_examplesite'
		alias: 'example'
		url: 'https://github.com/threefoldfoundation/www_examplesite'
		cat: SiteCat.web
		domains: ['example.threefold.io']
	}
	c.sites << SiteConfig{
		name: 'info_threefold'
		alias: 'threefold'
		// url: 'https://github.com/threefoldfoundation/info_threefold'
		url: 'https://github.com/threefoldfoundation/info_foundation_archive'
		domains: ['info.threefold.io']
	}
	// c.sites << SiteConfig{
	// 	name: 'info_marketplace'
	// 	alias: 'marketplace'
	// 	url: 'https://github.com/threefoldfoundation/info_marketplace'
	// }
	c.sites << SiteConfig{
		name: 'info_sdk'
		alias: 'sdk'
		url: 'https://github.com/threefoldfoundation/info_sdk'
		domains: ['sdk.threefold.io', 'sdk_info.threefold.io']
	}
	c.sites << SiteConfig{
		name: 'info_legal'
		alias: 'legal'
		url: 'https://github.com/threefoldfoundation/info_legal'
		domains: ['legal.threefold.io', 'legal_info.threefold.io']
	}
	c.sites << SiteConfig{
		name: 'info_cloud'
		alias: 'cloud'
		url: 'https://github.com/threefoldfoundation/info_cloud'
		domains: ['cloud_info.threefold.io']
	}
	c.sites << SiteConfig{
		name: 'info_tftech'
		alias: 'tftech'
		url: 'https://github.com/threefoldtech/info_tftech'
		domains: ['info.threefold.tech']
	}
	c.sites << SiteConfig{
		name: 'info_digitaltwin'
		alias: 'twin'
		url: 'https://github.com/threefoldfoundation/info_digitaltwin.git'
		domains: ['twin_info.threefold.io']
	}
	c.sites << SiteConfig{
		name: 'data_threefold'
		alias: 'data'
		url: 'https://github.com/threefoldfoundation/data_threefold'
		cat: SiteCat.data
		domains: []string{}
	}
}
