module tmux

import os
import vredis2

struct Tmux {
mut:
	sessions map[string]Session
}

pub fn new() Tmux {
	mut t := Tmux{
		sessions: map[string]Session{}
	}
	os.log('scan')
	t.scan()
	return t
}

pub fn (mut t Tmux) session_get(name string, restart bool) Session {
	name_l := name.to_lower()
	mut session := Session{}
	if name_l in t.sessions {
		session = t.sessions[name_l]
		if restart {
			session.restart()
		}
	} else {
		session = init_session(name_l)

		if restart {
			session.restart()
		}
		t.sessions[name_l] = session
	}
	return session
}

pub fn (mut t Tmux) scan() {
	exec_list := os.exec('tmux list-sessions') or { os.Result{
		exit_code: 1
		output: ''
	} }

	if exec_list.exit_code != 0 {
		// No server running
		return
	}

	mut done := map[string]bool{}

	out := os.exec("tmux list-windows -a -F '#{session_name}|#{window_name}|#{window_id}|#{pane_active}|#{pane_pid}|#{pane_start_command}'") or {
		os.Result{
			exit_code: 1
			output: ''
		}
	}
	for line in out.output.split_into_lines() {
		if line.contains('|') {
			line_arr := line.split('|')
			session_name := line_arr[0]
			window_name := line_arr[1]
			window_id := line_arr[2]
			pane_active := line_arr[3]
			pane_pid := line_arr[4]
			pane_start_command := line_arr[5] or { '' }

			key := session_name + '-' + window_name
			os.log(' - found session: $session_name $window_name id: $window_id $pane_active, $pane_pid, $pane_start_command')
			mut session := t.session_get(session_name, false)
			window_name_l := window_name.to_lower()

			if key in done {
				error('Duplicated window name: $key')
			}
			mut active := false
			if pane_active == '1' {
				active = true
			}
			if window_name != 'notused' {
				mut window := session.window_get(window_name_l)
				window.id = (window_id.replace('@', '')).int()
				window.pid = pane_pid.int()
				window.active = active
				done[key] = true
			}
			t.sessions[session_name] = session
		}
	}
}

fn (mut t Tmux) stop() {
	for _, mut session in t.sessions {
		session.stop()
	}
	mut redis := vredis2.connect('localhost:6379')?
	redis.del("tmux:active_session")?
	redis.del("tmux:active_window")?
}

pub fn (mut t Tmux) list() {
	for _, session in t.sessions {
		for _, window in session.windows {
			println('- $session.name: $window.name')
		}
	}
}
