module tmux

import os
import vredis2

struct Session {
mut:
	windows map[string]Window
	name    string
}

fn init_session(s_name string) Session {
	mut s := Session{
		name: s_name
	}
	os.log('tmux session: $s.name')
	s.windows = map[string]Window{}
	s.name = s.name.to_lower()
	return s
}

fn (mut s Session) create() {
	exec_new := os.exec("tmux new-session -d -s $s.name 'sh'") or {
		os.Result{
			exit_code: 1
			output: 'cannot create tmux session $s.name'
		}
	}
	exec_rename := os.exec("tmux rename-window -t 0 'notused'") or {
		os.Result{
			exit_code: 1
			output: ''
		}
	}
}

fn (mut s Session) restart() {
	s.stop()
	s.create()
}

fn (mut s Session) stop() {
	exec_stop := os.exec('tmux kill-session -t $s.name') or {
		os.Result{
			exit_code: 1
			output: ''
		}
	}
}

fn (mut s Session) activate() {
	mut redis := vredis2.connect('localhost:6379')?
	active_session := redis.get('tmux:active_session')?
	if s.name != active_session {
		exec_switch := os.exec('tmux switch -t $s.name') or {
			os.Result{
				exit_code: 1
				output: ''
			}
		}
		redis.set('tmux:active_session', s.name)?
	}
}

fn (mut s Session) execute(cmd string, check string) {
	os.log(cmd)
	os.log(check)
}

fn (mut s Session) window_exist(name string) bool {
	return name.to_lower() in s.windows
}

fn (mut s Session) window_get(name string) Window {
	name_l := name.to_lower()
	if name_l in s.windows {
		w := s.windows[name_l]
		return w
	} else {
		s.windows[name_l] = init_window(s, name_l, 0, false, 0)
		return s.windows[name_l]
	}
}
