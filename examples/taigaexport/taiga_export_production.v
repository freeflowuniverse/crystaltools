module main
import despiegk.crystallib.taiga
import os
// Generate wikis with users, projects, stories, issues and tasks
fn main() {
	url := 'https://circles.threefold.me' // Add your taiga url
	envs := os.environ()
	if ! ("TAIGA" in envs){
		println ("please specify TAIGA as: username:passwd for you taig instance")
		exit(1)
	}
	splitted := envs["TAIGA"].split(":")
	if splitted.len != 2{
		println ("please specify TAIGA as: username:passwd for you taig instance.\n$splitted")
		exit(1)
	}
	mut t := taiga.new(url, splitted[0], splitted[1], 100000,false) // Connect with username and password and cache time in seconds
	export_dir := '/tmp/taiga' // set export directory
	// t.cache_drop_all() or {panic(err)}
	taiga.export(export_dir, url) or {panic(err)}
}
