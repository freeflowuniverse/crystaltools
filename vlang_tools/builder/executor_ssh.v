module builder

import os
import rand

pub struct ExecutorSSH {
mut:
	ipaddr      IPAddress
	sshkey      string
	user        string //default will be root
	initialized bool
	retry       int = 5 // nr of times something will be retried before failing, need to check also what error is, only things which should be retried need to be done
}

fn (mut executor ExecutorSSH) init()?{
	if !executor.initialized {
		// todo : don't load if already running

		execute_cmd('pgrep -x ssh-agent || eval `ssh-agent -s`') or { return error("Could not start ssh-agent, error was: $err") }
		if executor.sshkey != '' {
			execute_cmd('ssh-add $executor.sshkey')
		}
		mut addr := executor.ipaddr.addr
		if addr == '' {
			addr = 'localhost'
		}
		mut fingerprint := ''
		cmd := "sh -c 'ssh-keyscan -H $executor.ipaddr.addr -p $executor.ipaddr.port -t ecdsa-sha2-nistp256 2>/dev/null >> ~/.ssh/known_hosts'"
		fingerprint = execute_cmd(cmd) or {
			return error("cannot add the ssh keys to known hosts")
		}
		// execute_cmd('echo "$fingerprint" ')
		executor.initialized = true
	}
}

pub fn (mut executor ExecutorSSH) exec(cmd string) ?string {
	
	println(executor.info())

	if executor.user != '' {
		return execute_cmd('ssh $executor.user@$executor.ipaddr.addr -p $executor.ipaddr.port "$cmd"')
	}
	return execute_cmd('ssh $executor.ipaddr.addr -p $executor.ipaddr.port "$cmd"')
}

pub fn (mut executor ExecutorSSH) file_write(path string, text string) ? {
	local_path := '/tmp/$rand.uuid_v4()'
	os.write_file(local_path, text)
	executor.upload(local_path, path)
	os.rm(local_path)
}

pub fn (mut executor ExecutorSSH) file_read(path string) ?string {
	local_path := '/tmp/$rand.uuid_v4()'
	executor.download(path, local_path)
	r:=os.read_file(local_path)?
	os.rm(local_path)
	return r
}

pub fn (mut executor ExecutorSSH) file_exists(path string) bool {
	output := executor.exec('test -f $path && echo found || echo not found') or { return false }
	if output == 'found' {
		return true
	}
	return false
}

// carefull removes everything
pub fn (mut executor ExecutorSSH) remove(path string) ? {
	executor.exec('rm -rf $path')
}

// upload from local FS to executor FS
pub fn (mut executor ExecutorSSH) download(source string, dest string) ?string {
	
	port := executor.ipaddr.port
	if executor.user != '' {
		return execute_cmd('rsync -avHPe "ssh -p$port" $executor.user@$executor.ipaddr.addr:$source $dest')
	}
	return execute_cmd('rsync -avHPe "ssh -p$port" $executor.ipaddr.addr:$source $dest')
}

// download from executor FS to local FS
pub fn (mut executor ExecutorSSH) upload(source string, dest string) ?string {
	
	port := executor.ipaddr.port
	if executor.user != '' {
		return execute_cmd('rsync -avHPe "ssh -p$port" $source -e ssh $executor.user@$executor.ipaddr.addr:$dest')
	}
	return execute_cmd('rsync -avHPe "ssh -p$port" $source -e ssh $executor.ipaddr.addr:$dest')
}

// get environment variables from the executor
pub fn (mut executor ExecutorSSH) environ_get() ?map[string]string {
	env := executor.exec('env') or { return error('can not get environment') }
	mut res := map[string]string{}
	if "\n" in res{
		for line in env.split('\n') {
			splitted := line.split('=')
			key := splitted[0]
			val := splitted[1]
			res[key] = val
		}
	}
	return res
}

/*
Executor info or meta data
accessing type Executor won't allow to access the 
fields of the struct, so this is workaround
*/
pub fn (mut executor ExecutorSSH) info() map[string]string {
	return {
		'category': 'ssh'
		'sshkey':   executor.sshkey,
		'user': executor.user,
		'ipaddress': executor.ipaddr.addr,
		'port': "$executor.ipaddr.port",
	}
}