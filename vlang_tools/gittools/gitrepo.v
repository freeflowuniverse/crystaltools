module gittools

import regex
import os

struct GitRepo {
path        string
pub:
	addr 		GitAddr
pub mut:
	state       GitStatus
}

fn (mut repo GitRepo) path_get() string {
	if repo.path == "" {
		return repo.addr.path_get()
	}else{
		return repo.path
	}	
}

fn (mut repo GitRepo) url_get() string {
	return repo.addr.url_get()
}

//if there are changes then will return 'true', otherwise 'false'
fn (mut repo GitRepo) changes() bool {
	if os.exists(repo.path_get()){
		return true
	}else{
		return true
	}
	return true
}




//pulls remote content in, will fail if there are local changes
fn (mut repo GitRepo) pull(){

	mut cmd := ""
	
	if os.exists(repo.path_get()){
		if ssh_agent_loaded() {repo.change_to_ssh()}

		println(ssh_agent_loaded())
		panic("aaa")
		
	}else{

		cmd = "mkdir -p ${repo.addr.path_account_get()} && cd ${repo.addr.path_account_get()} && git clone ${repo.addr.url}"

		if repo.addr.branch != "" {
			cmd += " -b $repo.addr.branch"
		}

		if repo.addr.depth != 0 {
			cmd += " --depth= ${repo.addr.depth}  && cd ${repo.addr.repo} && git fetch"
		}	
		

	}

	os.exec(cmd) or {panic(err)}
}


// `cd #{@path} && git clean -xfd && git checkout . && git checkout #{branch} && git pull`


//make sure we use ssh instead of https in the config file
fn (mut repo GitRepo) change_to_ssh(){

	path2 := repo.path_get()

	if ! os.exists(repo.path_get()){
		//nothing to do
		return
	}


	pathconfig := os.join_path(path2, ".git","config")
	if ! os.exists(pathconfig){
		panic("path: '$path2' is not a git dir, missed a .git/config file")
	}
	content := os.read_file(pathconfig) or {panic('Failed to load config $pathconfig')}

	mut re := regex.new()
	re.compile_opt(r"url *= *https:.*") or { panic(err) }	
	
	content2 := re.replace(content,repo.addr.url_ssh_get())

	if content != content2 {
		os.write_file(pathconfig,content2) or {panic('Failed to write config $pathconfig')}
	}


}

