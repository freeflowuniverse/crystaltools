module manifestor
import os
import rand


struct ExecutorSSH{
	mut:
		ipaddr 		  IPAddress
		sshkey        string = "~/.ssh/id_rsa" // path
		user		  string
		initialized   bool

	retry  int = 5 //nr of times something will be retried before failing, need to check also what error is, only things which should be retried need to be done
}

fn (mut executor ExecutorSSH) init(retry int) ExecutorLocal{
		mut local_executor := ExecutorLocal{retry: retry}
		if !executor.initialized{
			// todo : don't load if already running
			
			local_executor.exec("pgrep -x ssh-agent || eval `ssh-agent -s`") or {panic(err)}
			local_executor.exec("ssh-add $executor.sshkey")
			
			mut addr := executor.ipaddr.addr
			if addr == ""{
				addr = "localhost"
			}

			mut fingerprint := ""
			fingerprint = local_executor.exec("sh -c 'ssh-keyscan -H $executor.ipaddr.addr -p $executor.ipaddr.port.number -t ecdsa-sha2-nistp256 2>/dev/null >> ~/.ssh/known_hosts'") or {panic(err)}
			// local_executor.exec('echo "$fingerprint" ')
			executor.initialized = true
		}
		return local_executor
}

pub fn (mut executor ExecutorSSH) exec(cmd string) ?string {	
	mut local_executor := executor.init(executor.retry)
	
	if executor.user != ""{
		return local_executor.exec("ssh $executor.user@$executor.ipaddr.addr -p $executor.ipaddr.port.number $cmd")
	}
	return local_executor.exec("ssh $executor.ipaddr.addr -p $executor.ipaddr.port.number $cmd")
}

pub fn (mut executor ExecutorSSH) file_write(path string, text string) ? {	
	local_path := "/tmp/$rand.uuid_v4()"
	mut local_executor := executor.init(executor.retry)
	local_executor.file_write(local_path, text)
	executor.upload(local_path, path)
}	

pub fn (mut executor ExecutorSSH) file_read(path string) ?string {	
	local_path := "/tmp/$rand.uuid_v4()"
	executor.download(path, local_path)
	return os.read_file(local_path)
}

pub fn (mut executor ExecutorSSH) file_exists(path string) bool {
	output := executor.exec("test -f $path && echo found || echo not found") or {return false}
	if output == "found"{
		return true
	}
	return false
}

//carefull removes everything
pub fn (mut executor ExecutorSSH) remove(path string) ? {	
	executor.exec("rm -rf $path")
}

//upload from local FS to executor FS
pub fn (mut executor ExecutorSSH) download(source string, dest string) ?string {		
	mut local_executor := executor.init(executor.retry)
	port := executor.ipaddr.port.number
	if executor.user != ""{
		return local_executor.exec('rsync -avHPe "ssh -p$port" $executor.user@$executor.ipaddr.addr:$source $dest')
	}
	return local_executor.exec('rsync -avHPe "ssh -p$port" $executor.ipaddr.addr:$source $dest')
}

//download from executor FS to local FS
pub fn (mut executor ExecutorSSH) upload(source string, dest string) ?string {	
	mut local_executor := executor.init(executor.retry)
	port := executor.ipaddr.port.number
	if executor.user != ""{
		return local_executor.exec('rsync -avHPe "ssh -p$port" $source -e ssh $executor.user@$executor.ipaddr.addr:$dest')
	}
	return local_executor.exec('rsync -avHPe "ssh -p$port" $source -e ssh $executor.ipaddr.addr:$dest')
}

//get environment variables from the executor
pub fn (mut executor ExecutorSSH) environ_get() ?map[string]string {	
	env := executor.exec("env") or {return error("can not get environment")}
	mut res := map[string]string

	for line in env.split("\n") {
		splitted := line.split("=")
		key := splitted[0]
		val := splitted[1]
		res[key] = val
	}
	return res
}
