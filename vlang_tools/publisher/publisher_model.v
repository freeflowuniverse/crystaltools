module publisher

struct Publisher {
mut:
	gitlevel     int
pub mut:
	sites        []Site
	pages 		 []Page	
	files 		 []File
	site_name_id map[string]int	
}


pub fn (mut publisher Publisher) site_get_by_id(id int) ?&Site {
	if id > publisher.sites.len{
		return error("cannot get site with id: $id because not enough sites in the list")
	}
	return &publisher.sites[id]

pub fn (mut publisher Publisher) page_get_by_id(id int) ?&Page {
	if id > publisher.pages.len{
		return error("cannot get page with id: $id because not enough pages in the list")
	}
	return &publisher.pages[id]	

pub fn (mut publisher Publisher) file_get_by_id(id int) ?&File {
	if id > publisher.files.len{
		return error("cannot get file with id: $id because not enough files in the list")
	}
	return &publisher.files[id]		


////////////////////////////////////////////////////////////////



pub fn (mut publisher Publisher) site_exists(name string) bool {
	pagename := name_fix(name)
	return pagename in publisher.site_name_id
}

pub fn (mut publisher Publisher) file_exists(name string) bool {
	sitename,itemname = site_page_names_get(name)?
	if sitename==""{
		for site in publisher.sites {
			if itemname in site.file_name_id{
				return true
			}
		}
		return false
	}else{
		site = publisher.site_get(sitename)?
		return itemname in site.file_name_id
	}
}

pub fn (mut publisher Publisher) page_exists(name string) bool {
	sitename,itemname = site_page_names_get(name)?
	if sitename==""{
		for site in publisher.sites {
			if itemname in site.page_name_id{
				return true
			}
		}
		return false
	}else{
		site = publisher.site_get(sitename)?
		return itemname in site.page_name_id
	}
}



////////////// GET BY NAME

pub fn (mut publisher Publisher) site_get(name string) ?&Site {
	pagename := name_fix(name)
	if pagename in publisher.site_name_id{
		return publiser.site_get_by_id(publisher.site_name_id[pagename])
	}
	return error('cannot find site: $pagename')
}


// name in form: 'sitename:filename' or 'filename'
pub fn (mut publisher Publisher) file_get(name string) ?&File {
	sitename,itemname = site_page_names_get(name)?
	res = []int
	if sitename==""{
		for site in publisher.sites {
			if itemname in site.page_name_id{
				res << site.file_name_id[itemname]
			}
		}
	}else{
		site = publisher.site_get(sitename)?
		if itemname in site.file_name_id{
			return publisher.file_get_by_id(site.file_name_id[itemname])
		}
	}
	if res.len==0{
		return error("Could not find file: '$name'")
	}else if res.len>1{
		return error("Found more than 1 file with name: '$name'")
	}else{
		return publisher.file_get_by_id(res[0])
	}	
}

// name in form: 'sitename:pagename' or 'pagename'
pub fn (mut publisher Publisher) page_get(name string) ?&Page {
	sitename,itemname = site_page_names_get(name)?
	res = []int
	if sitename==""{
		for site in publisher.sites {
			if itemname in site.page_name_id{
				res << site.page_name_id[itemname]
			}
		}
	}else{
		site = publisher.site_get(sitename)?
		if itemname in site.page_name_id{
			return publisher.page_get_by_id(site.page_name_id[itemname])
		}
	}
	if res.len==0{
		return error("Could not find page: '$name'")
	}else if res.len>1{
		return error("Found more than 1 page with name: '$name'")
	}else{
		return publisher.page_get_by_id(res[0])
	}	
}
