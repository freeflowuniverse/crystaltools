module manifestor
import os


struct ExecutorSSH{
	ipaddr IPAddress
}


pub fn (mut executor ExecutorSSH) exec(cmd string) ?string {	
	println(cmd)
	panic("implement")
	if e.exit_code == 0 { 
		return e.output
	} else {
		return error("could not execute: $cmd\n Error was:$e")
	}
}

pub fn (mut executor ExecutorSSH) file_write(path string, text string) ? {	
	panic("implement")
	return os.write_file(path, text) ?
}

pub fn (mut executor ExecutorSSH) file_read(path string) ?string {	
	panic("implement")
	return os.read_file(path) ?
}

pub fn (mut executor ExecutorSSH) file_exists(path string) bool {	
	panic("implement")
	return os.file_exists(path)
}

//carefull removes everything
pub fn (mut executor ExecutorSSH) remove(path string) ? {	
	panic("implement")
	if os.is_file(path) || os.is_link(path){
		return os.rm(path) ?
	}else if os.is_dir(path) {
		return os.rmdir_all(path) ?
	}
}

//upload from local FS to executor FS
pub fn (mut executor ExecutorSSH) upload(source string, dest string) ? {		
	panic ("not implemented, suggest to use rsync")
}

//download from executor FS to local FS
pub fn (mut executor ExecutorSSH) download(source string, dest string) ? {	
	panic ("not implemented")
}

//get environment variables from the executor
pub fn (mut executor ExecutorSSH) environ_get() map[string]string {	
	panic("implement")
	return os.environ
}
