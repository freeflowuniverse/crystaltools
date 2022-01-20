module main
import despiegk.crystallib.taiga
// Generate wikis with users, projects, stories, issues and tasks
fn main() {
	url := 'https://staging.circles.threefold.me' // Add your taiga url
	singleton := taiga.new(url, 'admin', '123123', 100000) // Connect with username and password and cache time in seconds
	export_dir := '/tmp/taiga' // set export directory
	taiga.export(export_dir, url) or {panic(err)}
}
