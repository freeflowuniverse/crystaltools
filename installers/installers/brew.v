module installers

import myconfig
import process

pub fn brew_remove(conf &myconfig.ConfigRoot) ? {
	script := '
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"

	#needs to be done with sudo
	rm -rf /usr/local/Frameworks/
	rm -rf /usr/local/Homebrew/
	rm -rf /usr/local/bin/
	rm -rf /usr/local/etc/
	rm -rf /usr/local/go/
	rm -rf /usr/local/include/
	rm -rf /usr/local/lib/
	rm -rf /usr/local/opt/
	rm -rf /usr/local/sbin/
	rm -rf /usr/local/share/
	rm -rf /usr/local/var/
	'

	process.execute_silent(script) ?
}
