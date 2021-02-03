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
	mut out := ""
	mut job := Job{}
	job.cmd = cmd
	job.start = time.now()	
	mut cleanuppath := ""
	cleanuppath, job.args = cmd_to_args(cmd2)?

	if cmd.logcmd{
		println("execute: $cmd2")
	}	
	// println("execute: $args")

	mut p := os.new_process(job.args[0])
	p.set_redirect_stdio()
	p.set_args(job.args[1..job.args.len])
	p.run()

	if !p.is_alive() || p.code>0 {
		//didn't start, will restart but write to text file (adding \n will trigger that)
		cleanuppath, job.args = cmd_to_args(cmd2+"\n")?
		p = os.new_process(job.args[0])
		p.set_redirect_stdio()
		p.set_args(job.args[1..job.args.len])
		p.run()
	}

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
	if cleanuppath!=""{os.rm(cleanuppath) or {}}

	if job.exit_code > 0{
		if cmd.die{
			if cleanuppath!=""{os.rm(cleanuppath) or {}}
			return error("Cannot execute:\n$job")
		}else{
			if job.error == ""{
				job.error = "unknown"
			}			
		}
	}
	return job

}




//write temp file and return path
pub fn temp_write(text string) ? string {
	mut tmpdir := "/tmp"
	if ! os.exists("/tmp"){
		tmpdir =  os.environ()["TMPDIR"] or {panic("cannot find TMPDIR in os.environment variables.")}
	}
	mut tmppath := ""
	if ! os.exists("$tmpdir/execscripts/"){
			os.mkdir("$tmpdir/execscripts") or {return error("Cannot create $tmpdir/execscripts,$err")}
		}
	for i in 1..1000{
		tmppath = "$tmpdir/execscripts/exec_${i}.sh"
		if ! os.exists(tmppath){
			break
		}
	}
	os.write_file(tmppath,text) ?
	return tmppath
}


fn check_write(text string) bool{
	if texttools.check_exists_outside_quotes(text,["<",">","|"]){return true}
	if "\n" in text {return true}
	return false
}

//process commands to arguments which can be given to a process manager
//will return temporary path and args
pub fn cmd_to_args(cmd string)? (string,[]string){
	mut cleanuppath := ""
	mut text:=cmd

	if text.contains("&&") && !check_write(text){			
		text = text.replace("&&","\n")
		text="set -ex\n$text"
	}

	if check_write(text) {
		//will write temp file which can then be executed

		text = texttools.dedent(text)		
		if ! text.ends_with("\n"){
			text += "\n"
		}
		println("write\n$text")
		cleanuppath = temp_write(text)or {return error("error: cannot write $err")}
		text = "/bin/bash '$cleanuppath'"	
	}else{
		for x in ["find","ls"]{
			if text.starts_with("$x "){
				if "\"" in text{
					return error("Cannot embed string in \"\"  because is already using in $text")
				}
				text= "bash -c \"${text}\""
			}
		}
	}
	mut args := texttools.text_to_args(text)?

	//get the path of the file
	if ! args[0].starts_with("/"){
		args[0] = os.find_abs_path_of_executable(args[0])?
	}	
	return cleanuppath,args

}