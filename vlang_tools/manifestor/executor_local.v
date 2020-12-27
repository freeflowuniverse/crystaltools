module manifestor
import os

pub fn (mut executor ExecutorLocal) exec(cmd string) ?string {	
	println(cmd)
	e := os.exec("$cmd") or { 
        return error("could not find command: $cmd")
    }
	if e.exit_code == 0 { 
		return e.output
	} else {
		return error("could not execute: $cmd\n Error was:$e")
	}
}

pub fn (mut executor ExecutorLocal) file_write(path string, text string) ? {	
	return os.write_file(path, text) ?
}

pub fn (mut executor ExecutorLocal) file_read(path string) ?string {	
	return os.read_file(path) ?
}

pub fn (mut executor ExecutorLocal) file_exists(path string) bool {	
	return os.file_exists(path)
}

//carefull removes everything
pub fn (mut executor ExecutorLocal) remove(path string) ? {	
	if os.is_file(path) || os.is_link(path){
		return os.rm(path) ?
	}else if os.is_dir(path) {
		return os.rmdir_all(path) ?
	}
}

//upload from local FS to executor FS
pub fn (mut executor ExecutorLocal) upload(source string, dest string) ? {	
	panic ("not implemented, suggest to use rsync")
}

//download from executor FS to local FS
pub fn (mut executor ExecutorLocal) download(source string, dest string) ? {	
	panic ("not implemented")
}

//get environment variables from the executor
pub fn (mut executor ExecutorLocal) environ_get() map[string]string {	
	return os.environ
}
