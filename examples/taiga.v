	
	
module main
import despiegk.crystallib.taiga


fn main() {

	// mut t := taiga.new('https://staging.circles.threefold.me', 'despiegk', 'kds007kds', 10000)
	mut t := taiga.new('https://circles.threefold.me', 'despiegk', 'kds007kds', 10000)
	t.cache_drop() or {panic("Can't drop cache")}
	// println('Taiga Client: $t')
	mut projects := t.projects() or { panic('cannot fetch projects. $err') }
	// println(projects)

	//TODO: does not fetch any stories
	stories:= t.stories() or { panic('cannot fetch stories. $err') }
	println(stories)
	println(stories.len)

	mut project :=projects[3]
	println(project)

	mut stories2 :=project.stories() or { panic('cannot fetch stories for project. $project.name \n$err') }
	println(stories2)

}