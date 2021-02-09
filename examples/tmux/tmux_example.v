import tmux

fn tmuxtest() ? bool {
	// Create Tmux object, scan function called inside new
	mut t := tmux.new()
	
	// List tmux
	t.list()

	// Get/Create if not found tmux session
	mut test_session := t.session_get("test_session", true)
	assert test_session.name == "test_session"
	
	// Get/Create if not found tmux window in test_session
	mut test_window := test_session.window_get("test_window")
	assert test_window.name == "test_window"
	t.scan()
	// Stop all sessions
	t.stop()

	return true
}

fn main() {
	tmuxtest() or { panic('err: $err | errcode: $errcode') }
}
