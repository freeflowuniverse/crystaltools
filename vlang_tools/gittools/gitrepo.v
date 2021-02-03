module gittools
import os
import process

struct GitRepo {
id        int  [skip]	
pub:
	path        string
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
fn (mut repo GitRepo) changes() ?bool {
	cmd := "cd ${repo.addr.path_get()} && git status"
	out := process.execute_silent(cmd) or {
		return error("Could not execute command to check git status on $repo.path\ncannot execute $cmd")		
	}	
	// println(out)
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
fn (mut repo GitRepo) pull(args PullArgs) ?{

	mut cmd := ""
	
	if os.exists(repo.path_get()){
		if ssh_agent_loaded() {
				repo.change_to_ssh() or {
					if err != ""{
						return error("cannot change to ssh for $repo.path")
					} 
				}
			}

		if args.force{
			if repo.addr.branch =="" {
				cmd = "cd ${repo.path_get()} && git clean -xfd && git checkout ."
			}else{
				cmd = "cd ${repo.path_get()} && git clean -xfd && git checkout . && git checkout ${repo}"
			}
			process.execute_silent(cmd) or {
				return error("Cannot pull repo: ${repo.path}. Error was $err")
			}
		}
		cmd = "cd ${repo.addr.path_get()} && git pull"
		
	}else{

		cmd = "mkdir -p ${repo.addr.path_account_get()} && cd ${repo.addr.path_account_get()} && git clone ${repo.addr.url_get()}"

		// println(cmd)

		if repo.addr.branch != "" {
			cmd += " -b $repo.addr.branch"
		}

		// if repo.addr.depth != 0 {
		// 	cmd += " --depth= ${repo.addr.depth}  && cd ${repo.addr.name} && git fetch"
		// }
	}
	process.execute_silent(cmd) or {return error("Cannot pull repo: ${repo.path}. Error was $err")}
}

fn (mut repo GitRepo) commit(msg string)?{

	// cmd := "cd ${repo.addr.path_get()} && git add . -A && git commit -m \"${msg}\""
	// println(builder.execute_cmd(cmd).output or {return(err)})

}





//make sure we use ssh instead of https in the config file
fn (mut repo GitRepo) change_to_ssh()?{

	path2 := repo.path_get()
	if ! os.exists(path2){
		//nothing to do
		return
	}

	pathconfig := os.join_path(path2, ".git","config")
	if ! os.exists(pathconfig){
		return error("path: '$path2' is not a git dir, missed a .git/config file. Could not change git to ssh repo.")
	}
	content := os.read_file(pathconfig) or {return error('Failed to load config $pathconfig for sshconfig')}

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
		os.write_file(pathconfig,result.join_lines()) or {return error('Failed to write config $pathconfig in change to ssh')}
	}


}

