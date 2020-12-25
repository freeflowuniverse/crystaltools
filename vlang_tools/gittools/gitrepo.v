module gittools

import os

struct GitRepo {
path        string
pub mut:
	addr 		GitAddr
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
	cmd := "cd ${repo.addr.path_get()} && git status"
	result := os.exec(cmd) or {panic(err)}
	if result.exit_code>0{
		panic("cannot execute $cmd")
	}	
	out := result.output
	println(out)
	if out.contains("Untracked files"){
		return true
	}else if out.contains("Your branch is ahead of"){
		return true
	}else if out.contains("Changes not staged for commit"){
		return true
	}else if out.contains("nothing to commit"){
		return false
	}else{
		return true
	}
	// println(out)
	return true
}


struct PullArgs{
	force bool
}


//pulls remote content in, will fail if there are local changes
// when using force:true it means we reset, overwrite all changes
fn (mut repo GitRepo) pull(args PullArgs){

	mut cmd := ""
	
	if os.exists(repo.path_get()){
		if ssh_agent_loaded() {repo.change_to_ssh()}

		if args.force{
			if repo.addr.branch =="" {
				cmd = "cd ${repo.path_get()} && git clean -xfd && git checkout ."
			}else{
				cmd = "cd ${repo.path_get()} && git clean -xfd && git checkout . && git checkout ${repo}"
			}
			os.exec(cmd) or {panic(err)}
		}
		cmd = "cd ${repo.addr.path_get()} && git pull"
		
	}else{

		cmd = "mkdir -p ${repo.addr.path_account_get()} && cd ${repo.addr.path_account_get()} && git clone ${repo.addr.url_get()}"

		// println(cmd)

		if repo.addr.branch != "" {
			cmd += " -b $repo.addr.branch"
		}

		if repo.addr.depth != 0 {
			cmd += " --depth= ${repo.addr.depth}  && cd ${repo.addr.repo} && git fetch"
		}	
		

	}

	os.exec(cmd) or {panic(err)}
}

fn (mut repo GitRepo) commit(msg string){

	// cmd := "cd ${repo.addr.path_get()} && git add . -A && git commit -m \"${msg}\""
	// println(os.exec(cmd).output or {panic(err)})

}





//make sure we use ssh instead of https in the config file
fn (mut repo GitRepo) change_to_ssh(){

	path2 := repo.path_get()
	if ! os.exists(path2){
		//nothing to do
		return
	}

	pathconfig := os.join_path(path2, ".git","config")
	if ! os.exists(pathconfig){
		panic("path: '$path2' is not a git dir, missed a .git/config file")
	}
	content := os.read_file(pathconfig) or {panic('Failed to load config $pathconfig')}

	mut result := []string{}
	mut line2 := ""
	mut found := false
	for line in content.split_into_lines() {
		//see if we can find the line which has the url
		pos := line.index("url =") or {0}
		if pos > 0 {			
			line2 = line[0..pos]+"url = "+repo.url_get()
			found = true
		}else{
			line2=line
		}
		result << line2
	}

	if found {
		os.write_file(pathconfig,result.join_lines()) or {panic('Failed to write config $pathconfig')}
	}


}

