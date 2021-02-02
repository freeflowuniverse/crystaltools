module process
import os
import time
import texttools
import io.util

pub struct Command{
	pub mut:
		cmd string
		timeout int = 600
		stdout bool = true
		stdout_log bool = true
		die bool = true
		logcmd bool
		args map[string]string
		node string
}

pub struct Job{
	pub mut:
		start time.Time
		end time.Time
		cmd Command
		args []string
		output string
		error string
		exit_code int
}


//cmd is the cmd to execute can use ' ' and spaces
// if \n in cmd it will write it to ext and then execute with bash
//if die==false then will just return returncode,out but not return error
//if stdout will show stderr and stdout
//
// if cmd starts with find or ls, will give to bash -c so it can execute
// if cmd has no path, path will be found
// $... are remplaced by environment arguments
// e.g. $TMPDIR will replace to the temp directory  (needs to be uppercase !) TODO:IMPLEMENT
//
// Command argument:
//   cmd string
//   timeout int = 600
//   stdout bool = true
//   die bool = true
//	 logcmd bool  //if we keep the output in the job command
//	 node Node    //e.g. 192.13.3.3:2022 (is ip address)
//   args map[string]string  // these arguments are replaced in the text given
// 
// returns Job:
//     start time.Time
//     end time.Time
//     cmd Command (links to the Command argument)
//     args []string (args as given to the process)
//     output string
//     error string
//     exit_code int  (return code)
//
// return Job
// out is the output
pub fn execute(cmd Command) ? Job {
	mut cmd2 := cmd.cmd
	mut cleanup:=false
	mut out := ""
	mut job := Job{}
	job.cmd = cmd
	job.start = time.now()	
	mut cleanuppath := ""
	if "\n" in cmd2 {
		//will write temp file which can then be executed
		mut tmpfile,tmpfile_path := util.temp_file({})?
		cleanuppath = tmpfile_path
		cmd2 = texttools.dedent(cmd2)		
		if ! cmd2.ends_with("\n"){
			cmd2 += "\n"
		}
		tmpfile.write_str(cmd2)?
		tmpfile.close()
		job.cmd.cmd = cmd2
		cmd2 = "/bin/bash '$tmpfile_path'"
		cleanup = true		
	}else{
		for x in ["find","ls"]{
			if cmd2.starts_with("$x "){
				if "\"" in cmd2{
					return error("Cannot embed string in \"\"  because is already using in $cmd2")
				}
				cmd2= "bash -c \"${cmd2}\""
			}
		}
	}
	if cmd.logcmd{
		println("execute: $cmd2")
	}
	job.args = texttools.text_to_args(cmd2)

	//get the path of the file
	if ! job.args[0].starts_with("/"){
		job.args[0] = os.find_abs_path_of_executable(job.args[0])?
	}

	// println("execute: $args")

	mut p := os.new_process(job.args[0])
	p.set_redirect_stdio()
	p.set_args(job.args[1..job.args.len])
	p.run()

	start := time.now().unix_time()
	for {
		if p.is_alive(){
			out = p.stdout_read()
			if out !=""{
				if cmd.stdout{println(out)}		
				if cmd.stdout_log{		
					job.output+=out
				}
			}			
			if time.now().unix_time() > start + cmd.timeout{
				job.exit_code = 100
				job.error = "timeout"
				break
			}
		}else{
			break
		}
	}

	if p.code > 0{
		job.exit_code = p.code
	}

	job.end = time.now()
	if cleanup{os.rm(cleanuppath)or {}}

	if job.exit_code > 0{
		if cmd.die{
			if cleanup{os.rm(cleanuppath) or {}}
			return error("Cannot execute:\n$job")
		}else{
			if job.error == ""{
				job.error = "unknown"
			}			
		}
	}
	return job

}

