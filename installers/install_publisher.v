module main
import process
import cli
import os
import gittools
import builder
import texttools

fn main() {
	
	mut app := cli.Command{
		name: 'publishing tools',
		description: 'publishing tools',
		execute: fn (cmd cli.Command) ? {
					ourreset := true
					if ourreset{
						reset() or {println(" ** ERROR: cannot reset. Error was:\n$err") exit(1)}
					}
					step1() or {println(" ** ERROR: cannot prepare system. Error was:\n$err") exit(1)}
					getsites() or {println(" ** ERROR: cannot get web & wiki sites. Error was:\n$err") exit(1)}
					npm() or {println(" ** ERROR: cannot install npm. Error was:\n$err") exit(1)}
					website_install("www_threefold_farming",true,ourreset) or {println(err)}
					website_install("www_threefold_cloud",false,ourreset) or {println(err)}
					website_install("www_threefold_twin",false,ourreset) or {println(err)}
					website_install("www_vdc",false,ourreset) or {println(err)}
					// website_install("www_tfnow",false) or {println(err)}					
					// website_install("www_conscious_internet",false) or {println(err)}
				}
		commands: [
			cli.Command{
				name: 'export'
				execute: fn (cmd cli.Command) ? {
					println("export")

				}
			},
		]
	}
	app.setup()
	app.parse(os.args)
}


fn base_path_get() string {
	return "${os.home_dir()}/.publisher"
}

fn code_path_get() string {
	return "${os.home_dir()}/codesync"
}

fn nodejs_path_get() string {
	base := base_path_get()
	// return "${base}/versions/node/v15.8.0"
	return "${base}/versions/node/v14.15.4"	
}


fn step1()? {

	base := base_path_get()

	mut node := builder.node_get({}) or {println(" ** ERROR: cannot load node. Error was:\n$err") exit(1)}
	node.platform_prepare() ?

	if !os.exists(base){
		os.mkdir(base) or {panic(err)}
	}

	println(" - installed base requirements")

}

fn getsites()? {

	base := code_path_get()

	if !os.exists("$base/codesync"){
		os.mkdir("$base/codesync") or {panic(err)}
	}

	//get publisher, check for all wiki's
	mut gt := gittools.new("$base") or {panic ("cannot load gittools:$err")}
	
	//will only pull if it does not exists
	_ := gt.repo_get_from_url("https://github.com/threefoldtech/info_tftech") or {panic ("cannot load info_tftech:$err")}
	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/www_threefold_cloud") or {panic ("cannot load repo:$err")}
	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/www_threefold_farming") or {panic ("cannot load repo:\n$err")}
	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/www_threefold_twin") or {panic ("cannot load repo:\n$err")}
	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/www_vdc") or {panic ("cannot load repo:\n$err")}
	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/www_tfnow") or {panic ("cannot load repo:\n$err")}
	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/www_conscious_internet") or {panic ("cannot load repo:\n$err")}
	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/info_foundation") or {panic ("cannot load repo:$err")}
	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/info_tfgrid_sdk") or {panic ("cannot load repo:$err")}
	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/legal") or {panic ("cannot load repo:\n$err")}
	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/data_threefold") or {panic ("cannot load repo:\n$err")}

	println(" - get all code repositories.")

}


fn reset()? {
	base := base_path_get()
	assert base.len > 10 //just to make sure we don't erase all
	script := "
	set -e
	rm -rf $base
	"
	process.execute_silent(script) or {println("** ERROR: cannot reset the system.\n$err")  exit(1)}
	println(" - cleanup")
}

fn npm()? {

	base := base_path_get()

	mut node := builder.node_get({}) or {println(" ** ERROR: cannot load node. Error was:\n$err") exit(1)}
	node.platform_prepare() ?

	if ! os.exists('$base/nvm.sh'){

		script := "
		set -e
		rm -f $base/nvm.sh
		curl -s -o '$base/nvm.sh' https://raw.githubusercontent.com/nvm-sh/nvm/master/nvm.sh
		"
		process.execute_silent(script) or {println("cannot download nvm script.\n$err") exit(1)}
	}

	nodejspath := nodejs_path_get()
	if ! os.exists('${nodejspath}/bin/node'){
		println(" - will install nodejs (can take quite a while)")
		script := "
		set -e
		export NVM_DIR=$base
		source $base/nvm.sh
		nvm install --lts
		npm install -g grunt
		npm install -g gridsome
		npm install -g @gridsome/cli
		"
		process.execute_stdout(script) or {println("cannot install nodejs.\n$err") exit(1)}
	}

	println(" - nodejs installed")

}


// Initialize (load wikis) only once when server starts
fn website_install(name string, first bool, reset bool) ? {

	base := base_path_get()
	codepath := code_path_get()
	nodejspath := nodejs_path_get()

	mut gt := gittools.new(codepath) or {println ("ERROR: cannot load gittools:$err") exit(1)}

	mut repo := gt.repo_get({name:name}) or {println ("ERROR: cannot load gittools:$err") exit(1)}
	println( " - install website (can take long) on ${repo.path}")

	if reset{
		script6 := "
		
		cd ${repo.path}

		rm -f yarn.lock
		rm -rf .cache		
		rm -rf modules

		"
		process.execute_silent(script6) or {println("cannot install node modules for ${name}.\n${err}") exit(1)}
	}

	if first{
		script2 := "
		
		cd ${repo.path}

		rm -f yarn.lock
		rm -rf .cache		

		git pull
		
		source $base/nvm.sh
		
		nvm use --lts
		npm install

		rsync -ra --delete node_modules/ ${base}/node_modules/

		"
		process.execute_silent(script2) or {println("cannot install node modules for ${name}.\n${err}") exit(1)}
	}else{
		script3 := "
		
		cd ${repo.path}

		rm -f yarn.lock
		rm -rf .cache

		git pull ; echo 
		
		source $base/nvm.sh
		
		rsync -ra --delete ${base}/node_modules/ node_modules/ 

		nvm use --lts		
		npm install		

		"
		process.execute_silent(script3) or {println("cannot install node modules for ${name}.\n${err}") exit(1)}		

	}

	script4 := "
	
	cd ${repo.path}

	rm -f content/blog 
	rm -f content/person 
	rm -f content/news 
	rm -f content/project

	ln -s ${codepath}/data_threefold/content/blog content/blog
	ln -s ${codepath}/data_threefold/content/person content/person
	ln -s ${codepath}/data_threefold/content/news content/news
	ln -s ${codepath}/data_threefold/content/project content/project

	cd ${codepath}/data_threefold
	git pull ; echo 

	"
	process.execute_silent(script4) or {println("cannot link the data dir ${name}.\n${err}") exit(1)}	

	script_run := "

	cd ${repo.path}

	nvm use --lts

	export PATH=${nodejspath}/bin:\$PATH

	gridsome develop

	"

	os.write_file("${repo.path}/run.sh",texttools.dedent(script_run)) or {println("cannot write to ${repo.path}/run.sh\n$err")}


}
