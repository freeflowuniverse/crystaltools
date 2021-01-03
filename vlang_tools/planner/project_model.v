module planner

pub enum ProjectStatus {
	suggested
	approved
	started
	verify
	closed
}

pub struct Project {
pub mut:
	name         string
	state        ProjectStatus
	stories map[string]int

