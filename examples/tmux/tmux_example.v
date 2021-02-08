import tmux

fn tmuxtest() ? bool {
	// Create Tmux object, scan function called inside new
	mut t := tmux.new()

	// List all tmux sessions 
	t.list()

	// Get tmux session
	test_session := t.session_get("test", false)
	assert test_session.name == "test"
	// t.scan()
	t.list()
	// Stop all sessions
	t.stop()

	return true
}

fn main() {
	tmuxtest() or { panic('err: $err | errcode: $errcode') }
}

