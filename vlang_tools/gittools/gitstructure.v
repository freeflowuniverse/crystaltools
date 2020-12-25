module gittools

import os

pub enum GitStatus {
	unknown
	changes
	ok
	error
}

struct GitStructure {
	pub mut:
		repos []GitRepo
}


// the factory
pub fn new() GitStructure {
	mut gitstructure := GitStructure{}
	gitstructure.load("")
	return gitstructure
}

// will return first found git repo
// to use gitstructure.repo_get({account:"something",name:"myname"})
// or gitstructure.repo_get({name:"myname"})
pub fn (mut gitstructure GitStructure) repo_get(addr GitAddr) ?GitRepo {

	for repo_return in gitstructure.repos {
		if repo_return.addr.repo == addr.repo {
			if addr.account == "" {
				return repo_return
			}else{
				if addr.account == repo_return.addr.account {
					return repo_return
				}
			}
		}
	}

	//means we did not find
	return GitRepo{addr:addr}

	// return error("Could not find repo for account:'${addr.account}' name:'${addr.repo}'")

}



//find all git repo's, this goes very fast, no reason to cache
fn (mut gitstructure GitStructure) load(path string) {
	mut path1 := ""
	if path == "" {
		path1 = "${os.home_dir()}/code/"
	}else{
		path1 = path
	}
	items := os.ls(path1) or { panic("cannot find $path1")}
	mut pathnew:= ""
	for item in items {
		pathnew = os.join_path(path1, item)
		if os.is_dir(pathnew) {
			// println(" - $pathnew")		
			if os.exists(os.join_path(pathnew, ".git")){
				gitaddr := addr_get_from_path(pathnew)
				gitstructure.repos << GitRepo{addr:gitaddr,path:pathnew}
				continue
			}
			if item.starts_with('.') {				
				continue
			}
			if item.starts_with('_') {
				continue
			}
			gitstructure.load(pathnew)
		}
	}	
}
