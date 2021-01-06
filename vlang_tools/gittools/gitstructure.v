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

//will get repo starting from url, if the repo does not exist, only then will pull
pub fn (mut gitstructure GitStructure) repo_get_from_url(url string) ?&GitRepo {

	addr := addr_get_from_url(url) or {return error("cannot get addr from url:$err")}
	addr2 := GitGetArgs{name:addr.name, account:addr.account}

	if ! gitstructure.repo_exists(addr2) {
		//repo does not exist yet
		gitstructure.repos << GitRepo{path:addr.path_get(),addr:addr,id:gitstructure.repos.len}
		_:= gitstructure.repo_get(addr2) or { 
			//means could not pull need to remove the repo from the list again
			gitstructure.repos.delete_last()
			return error("Could not clone the repo from ${url}.\nError:$err")
		}

	}

	mut r := gitstructure.repo_get(addr2) or {return error("cannot load git $url\nerror:$err")}
	return r
}

struct GitGetArgs {
mut:
	account  string
	name     string //is the name of the repository
}

// will return first found git repo
// to use gitstructure.repo_get({account:"something",name:"myname"})
// or gitstructure.repo_get({name:"myname"})
pub fn (mut gitstructure GitStructure) repo_get(addr GitGetArgs) ?&GitRepo {

	for r in gitstructure.repos {
		if r.addr.name == addr.name {
			if addr.account == "" || addr.account == r.addr.account {
				mut r2:= &gitstructure.repos[r.id]
				if ! os.exists(r2.path){
					//is not checked out yet need to do
					println("repo on ${r2.path} did not exist yet will pull.")
					r2.pull({})?
				}			
				return r2	
			}
		}
	}
	return error("Could not find repo for account:'${addr.account}' name:'${addr.name}'")
}

// to use gitstructure.repo_get({account:"something",name:"myname"})
// or gitstructure.repo_get({name:"myname"})
pub fn (mut gitstructure GitStructure) repo_exists(addr GitGetArgs) bool {
	for r in gitstructure.repos {
		if r.addr.name == addr.name {
			if addr.account == "" || addr.account == r.addr.account {
				return true
			}
		}
	}
	return false

}



//find all git repo's, this goes very fast, no reason to cache
fn (mut gitstructure GitStructure) load(path string)? {
	gitstructure.repos = []GitRepo{}
	mut path1 := ""
	if path == "" {
		path1 = "${os.home_dir()}/code/"
	}else{
		path1 = path
	}
	items := os.ls(path1) or { return error("cannot load gitstructure because cannot find $path1")}
	mut pathnew:= ""
	for item in items {
		pathnew = os.join_path(path1, item)
		if os.is_dir(pathnew) {
			// println(" - $pathnew")		
			if os.exists(os.join_path(pathnew, ".git")){
				gitaddr := addr_get_from_path(pathnew) or {return error(err)}
				gitstructure.repos << GitRepo{addr:gitaddr,path:pathnew,id:gitstructure.repos.len}
				continue
			}
			if item.starts_with('.') {				
				continue
			}
			if item.starts_with('_') {
				continue
			}
			gitstructure.load(pathnew)?
		}
	}	
}
