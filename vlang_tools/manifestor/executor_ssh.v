module manifestor
import os
import rand


struct ExecutorSSH{
	mut:
		ipaddr IPAddress
	retry  int = 5 //nr of times something will be retried before failing, need to check also what error is, only things which should be retried need to be done
}

pub fn (mut executor ExecutorSSH) exec(cmd string) ?string {	
	mut local_executor := ExecutorLocal{retry: executor.retry}
	return local_executor.exec("ssh $executor.ipaddr.address() $cmd")
}

pub fn (mut executor ExecutorSSH) file_write(path string, text string) ? {	
	local_path := "/tmp/$rand.uuid_v4()"
	mut local_executor := ExecutorLocal{retry: executor.retry}
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
	mut local_executor := ExecutorLocal{retry: executor.retry}
	return local_executor.exec('rsync -avHPe "ssh -p$executor.ipaddr.port" $executor.ipaddr.addr:$source $dest')
}

//download from executor FS to local FS
pub fn (mut executor ExecutorSSH) upload(source string, dest string) ?string {	
	mut local_executor := ExecutorLocal{retry: executor.retry}
	return local_executor.exec('rsync -avHPe "ssh -p$executor.ipaddr.port" $source -e ssh $executor.ipaddr.addr:$dest')
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
