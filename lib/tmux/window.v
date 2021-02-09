module tmux

import os
import vredis2

struct Window {
pub mut:
	session Session
	name    string
	id      int
	active  bool
	pid     int
}

fn init_window(session Session, name string, id int, active bool, pid int) Window {
	mut w := Window{
		session: session
		name: name.to_lower()
		id: id
		active: active
		pid: pid
	}
	w.create()
	return w
}

fn (mut w Window) create() {
	w.session.activate()
	if w.active == false {
		os.exec('tmux new-window -t $w.session.name -n $w.name') or {
			os.Result{
				exit_code: 1
				output: ''
			}
		}
	}
}

fn (mut w Window) restart() {
	w.stop()
	w.create()
}

fn (mut w Window) stop() {
	if w.pid > 0 {
		os.exec('kill -9 $w.pid') or { os.Result{
			exit_code: 1
			output: ''
		} }
	}
	w.pid = 0
	w.active = false
	w.session.windows.delete(w.name)
}

fn (mut w Window) activate() {
	mut redis := vredis2.connect('localhost:6379') or { panic("Couldn't connect to redis client") }
	key := '$w.session.name:$w.name'
	active_window := redis.get('tmux:active_window') or {" - Couldn't get tmux:active_window"}
	if active_window != key || !w.active || w.pid == 0 {
		w.session.activate()
		if !w.active || w.pid == 0 {
			w.create()
		}
		os.exec('tmux select-window -t $w.name') or { os.Result{
			exit_code: 1
			output: ''
		} }
		redis.set('tmux:active_window', key) or { panic(" - Couldn't set tmux:active_window") }
	}
}

fn (mut w Window) execute(cmd string, check string, reset bool) {
	w.activate()
	os.log('window:$w.name execute:$cmd')
	if reset {
		w.restart()
	}
	os.exec('tmux send-keys -t $w.session.name $cmd Enter') or {
		os.Result{
			exit_code: 1
			output: ''
		}
	}
	if check != '' {
		error('implement')
		os.exec('tmux') or { os.Result{
			exit_code: 1
			output: ''
		} }
	}
}
