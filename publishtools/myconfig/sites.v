module myconfig

fn site_config(mut c ConfigRoot) {
	c.sites << SiteConfig{
		name: 'www_threefold_io'
		alias: 'wwwtf'
		url: 'https://github.com/threefoldfoundation/www_threefold_io'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_threefold_cloud'
		alias: 'wwwcloud'
		url: 'https://github.com/threefoldfoundation/www_threefold_cloud'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_threefold_farming'
		alias: 'wwwfarming'
		url: 'https://github.com/threefoldfoundation/www_threefold_farming'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_threefold_twin'
		alias: 'wwwtwin'
		url: 'https://github.com/threefoldfoundation/www_threefold_twin'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_threefold_marketplace'
		alias: 'wwwmarketplace'
		url: 'https://github.com/threefoldfoundation/www_threefold_marketplace'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_conscious_internet'
		alias: 'wwwconscious_internet'
		url: 'https://github.com/threefoldfoundation/www_conscious_internet'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_threefold_tech'
		alias: 'wwwtech'
		url: 'https://github.com/threefoldtech/www_threefold_tech'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_examplesite'
		alias: 'wwwexample'
		url: 'https://github.com/threefoldfoundation/www_examplesite'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'info_threefold'
		alias: 'threefold'
		url: 'https://github.com/threefoldfoundation/info_threefold'
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
	}
	c.sites << SiteConfig{
		name: 'info_legal'
		alias: 'legal'
		url: 'https://github.com/threefoldfoundation/info_legal'
	}
	c.sites << SiteConfig{
		name: 'info_cloud'
		alias: 'cloud'
		url: 'https://github.com/threefoldfoundation/info_cloud'
	}
	c.sites << SiteConfig{
		name: 'info_tftech'
		alias: 'tftech'
		url: 'https://github.com/threefoldtech/info_tftech'
	}
	c.sites << SiteConfig{
		name: 'info_digitaltwin'
		alias: 'twin'
		url: 'https://github.com/threefoldfoundation/info_digitaltwin.git'
	}
	c.sites << SiteConfig{
		name: 'data_threefold'
		alias: 'data'
		url: 'https://github.com/threefoldfoundation/data_threefold'
		cat: SiteCat.data
	}
}
