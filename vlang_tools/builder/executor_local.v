module builder

import os

struct ExecutorLocal {
	retry int = 1 // nr of times something will be retried before failing, need to check also what error is, only things which should be retried need to be done, default 1 because is local
}


pub fn execute_cmd(cmd string)?string{
	e := os.exec(cmd)?
	if e.exit_code == 0 {
		return e.output.trim('\n')
	} else {
		return error('could not execute: $cmd\n Error was:$e')
	}
}


pub fn (mut executor ExecutorLocal) exec(cmd string) ?string {
	return execute_cmd(cmd)
}

pub fn (mut executor ExecutorLocal) file_write(path string, text string) ? {
	return os.write_file(path, text)
}

pub fn (mut executor ExecutorLocal) file_read(path string) ?string {
	return os.read_file(path)
}

pub fn (mut executor ExecutorLocal) file_exists(path string) bool {
	return os.exists(path)
}

// carefull removes everything
pub fn (mut executor ExecutorLocal) remove(path string) ? {
	if os.is_file(path) || os.is_link(path) {
		return os.rm(path)
	} else if os.is_dir(path) {
		return os.rmdir_all(path)
	}
	return error('')
}

// get environment variables from the executor
pub fn (mut executor ExecutorLocal) environ_get() ?map[string]string {
	env := os.environ()
	if false {
		return error('can never happen')
	}
	return env
}

/*
Executor info or meta data
accessing type Executor won't allow to access the 
fields of the struct, so this is workaround
*/
pub fn (mut executor ExecutorLocal) info() map[string]string {
	return {
		'category': 'local'
	}
}

// upload from local FS to executor FS
pub fn (mut executor ExecutorLocal) upload(source string, dest string) ?string {
	panic('not implemented, suggest to use rsync')
}

// download from executor FS to local FS
pub fn (mut executor ExecutorLocal) download(source string, dest string) ?string {
	panic('not implemented')
}
