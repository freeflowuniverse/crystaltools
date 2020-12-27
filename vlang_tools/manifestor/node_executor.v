module manifestor
import os


pub fn (mut node Node) exec(cmd string) ?string {	
	match node.executor {
        ExecutorSSH {return node.executor.exec(cmd)}
        ExecutorLocal {return node.executor.exec(cmd)}
    }	
}

//TODO: need to implement the Others

pub fn (mut node Node) file_write(path string, text string) ? {	
}

pub fn (mut node Node) file_read(path string) ?string {	
}

pub fn (mut node Node) file_exists(path string) ?bool {	
}

//carefull removes everything
pub fn (mut node Node) remove(path string) ? {	
}

//upload from local FS to executor FS
pub fn (mut node Node) upload(source string, dest string) ? {	
}

//download from executor FS to local FS
pub fn (mut node Node) download(source string, dest string) ? {	
}

//get environment variables from the executor
pub fn (mut node Node) environ_get() ?map[string]string {	

}
