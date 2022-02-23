module main

import despiegk.crystallib.installers
import os
import cli
import despiegk.crystallib.publisher_core
import despiegk.crystallib.publisher_config
import despiegk.crystallib.gittools
import readline

fn flag_message_get(cmd cli.Command) string {
	flags := cmd.flags.get_all_found()
	msg := flags.get_string('message') or {
		msg := readline.read_line('Message for commit?:') or { panic(err) }
		return msg
	}
	return msg
}

fn flag_names_get(cmd cli.Command) []string {
	flags := cmd.flags.get_all_found()
    repo := flags.get_string('repo') or { return []string{} }
	return [repo]
}

fn main() {

	pullflag := cli.Flag{
		name: 'pull'
		abbrev: 'p'
		description: "do you want to pull the git repo's"
		flag: cli.FlagType.bool
	}

	resetflag := cli.Flag{
		name: 'reset'
		abbrev: 'd'
		description: 'will reset the env before installing or pulling'
		flag: cli.FlagType.bool
	}

	cleanflag := cli.Flag{
		name: 'clean'
		abbrev: 'c'
		description: 'will clean the env before'
		flag: cli.FlagType.bool
	}

	messageflag := cli.Flag{
		name: 'message'
		abbrev: 'm'
		description: 'commit message'
		flag: cli.FlagType.string
	}

	repoflag := cli.Flag{
		name: 'repo'
		abbrev: 'r'
		description: 'repository name, can be part of name'
		flag: cli.FlagType.string
	}

	no_path_prefix_flag := cli.Flag{
		name: 'nopathprefix'
		abbrev: 'p'
		description: 'Build website(s) without alias/path prefix'
		flag: cli.FlagType.bool
	}

	update_publishtools_flag := cli.Flag{
		name: 'update_pubtools'
		abbrev: 'u'
		description: 'update publishtools'
		flag: cli.FlagType.bool
	}

	publish_prod_flag := cli.Flag{
		name: 'production'
		abbrev: 'p'
		description: 'publish production'
		flag: cli.FlagType.bool
	}

	// INSTALL
	install_exec := fn (cmd cli.Command) ? {
		flags := cmd.flags.get_all_found()
		ourreset := flags.get_bool('reset') or { false }
		clean := flags.get_bool('clean') or { false }
		installers.web(ourreset,clean) ?
	}
	mut install_cmd := cli.Command{
		name: 'install'
		execute: install_exec
	}
	install_cmd.add_flag(pullflag)
	install_cmd.add_flag(resetflag)
	install_cmd.add_flag(cleanflag)

	// DEVELOP
	develop_exec := fn (cmd cli.Command)? {
		flags := cmd.flags.get_all_found()
		webrepo := flags.get_string('repo') or { '' }
		println(1)
		mut cfg := publisher_config.get() or {
			println('Could not load config:\n$err')
			exit(1)
		}
		println(2)
		if webrepo == '' {
			println(' - develop for wikis')

			mut publ := publisher_core.new(cfg) or {
				println('Could not load publisher for wiki.\nError:\n$err')
				exit(1)
			}
			publ.develop = true
			publisher_core.webserver_run(mut &publ) or {
				println('Could not run webserver for wiki.\nError:\n$err')
				exit(1)
			}
		} else {
			println(' - develop website: $webrepo')
			installers.website_develop([webrepo]) or {
				println('Could not develop wiki.Error:\n$err')
				exit(1)
			}
		}
	}

	mut develop_cmd := cli.Command{
		name: 'develop'
		usage: 'specify name of website to develop on, if not specified will show the wiki'
		execute: develop_exec
	}

	develop_cmd.add_flag(repoflag)

	// RUN
	run_exec := fn (cmd cli.Command) ? {

		cfg := publisher_config.get()?
		mut publ := publisher_core.new(cfg) ?
		publ.run()?
		// publisher_core.webserver_run(mut &publ) ?
	}
	mut run_cmd := cli.Command{
		description: 'run action commands as found in wikis as specified in EXECUTORSOURCE'
		name: 'run'
		execute: run_exec
		required_args: 0
	}

	// FLATTEN
	flatten_exec := fn (cmd cli.Command) ? {

		cfg := publisher_config.get()?
		mut publ := publisher_core.new(cfg) ?
		publ.flatten() ?
	}
	mut flatten_cmd := cli.Command{
		name: 'flatten'
		usage: 'specify name of website or wiki to flatten'
		execute: flatten_exec
		required_args: 0
	}
	flatten_cmd.add_flag(repoflag)

	// BUILD
	build_exec := fn (cmd cli.Command) ? {
		flags := cmd.flags.get_all_found()
		// cfg := publisher_config.get()?
		// mut publ := publisher_core.new(cfg) ?
		installers.website_build(flags.get_bool('reset') or { false },flag_names_get(cmd)) ?
	}
	mut build_cmd := cli.Command{
		name: 'build'
		usage: 'specify name of website or wiki to build'
		execute: build_exec
		required_args: 0
	}
	build_cmd.add_flag(repoflag)
	build_cmd.add_flag(no_path_prefix_flag)

	// LIST
	list_exec := fn (cmd cli.Command) ? {
		installers.sites_list([]) ?
	}
	mut list_cmd := cli.Command{
		name: 'list'
		execute: list_exec
	}

	// PULL
	pull_exec := fn (cmd cli.Command) ? {
		flags := cmd.flags.get_all_found()
		installers.sites_pull(flag_names_get(cmd),flags.get_bool('reset') or { false }) ?
	}
	mut pull_cmd := cli.Command{
		name: 'pull'
		execute: pull_exec
	}
	pull_cmd.add_flag(resetflag)
	pull_cmd.add_flag(repoflag)

	// EDIT
	edit_exec := fn (cmd cli.Command) ? {
		flags := cmd.flags.get_all_found()
		installers.site_edit(flags.get_string('repo') or { '' }) ?
	}
	mut edit_cmd := cli.Command{
		name: 'edit'
		execute: edit_exec
	}
	edit_cmd.add_flag(repoflag)

	// VERSION
	version_exec := fn (cmd cli.Command) ? {
		println('1.0.21')
	}
	mut version_cmd := cli.Command{
		name: 'version'
		execute: version_exec
	}

	// PUSHCOMMIT
	pushcommit_exec := fn (cmd cli.Command) ? {
		installers.sites_pushcommit(flag_message_get(cmd),flag_names_get(cmd)) ?
	}
	mut pushcommit_cmd := cli.Command{
		name: 'pushcommit'
		execute: pushcommit_exec
	}
	pushcommit_cmd.add_flag(messageflag)
	pushcommit_cmd.add_flag(repoflag)

	// COMMIT
	commit_exec := fn (cmd cli.Command) ? {
		// flags := cmd.flags.get_all_found()
		msg := flag_message_get(cmd)
		installers.sites_commit(msg,flag_names_get(cmd)) ?
	}
	mut commit_cmd := cli.Command{
		name: 'commit'
		execute: commit_exec
	}
	commit_cmd.add_flag(messageflag)
	commit_cmd.add_flag(repoflag)

	// DISCARD
	discard_exec := fn (cmd cli.Command) ? {
		installers.sites_discard(flag_names_get(cmd)) ?
	}
	mut discard_cmd := cli.Command{
		name: 'discard'
		execute: discard_exec
	}
	discard_cmd.add_flag(repoflag)


	// PUSH
	push_exec := fn (cmd cli.Command) ? {
		installers.sites_push(flag_names_get(cmd)) ?
	}
	mut push_cmd := cli.Command{
		name: 'push'
		execute: push_exec
	}
	push_cmd.add_flag(resetflag)
	push_cmd.add_flag(repoflag)

	// UPDATE
	update_exec := fn (cmd cli.Command) ? {
		installers.publishtools_update() ?

	}
	mut update_cmd := cli.Command{
		name: 'update'
		usage: 'update the tool'
		execute: update_exec
		required_args: 0
	}

	// REMOVE CHANGES
	removechanges_exec := fn (cmd cli.Command) ? {

		installers.sites_removechanges(flag_names_get(cmd)) ?
	}
	mut removechangese_cmd := cli.Command{
		name: 'removechanges'
		usage: 'remove changes made'
		execute: removechanges_exec
		required_args: 0
	}

	// DNS
	dns_execute := fn (cmd cli.Command) ? {
		mut args := os.args.clone()
		if args.len == 3 {
			if args[2] == 'off' {
				publisher_core.dns_off(true)?
				return
			} else if args[2] == 'on' {
				publisher_core.dns_on(true)?
				return
			}
		}
		println('usage: publishtools dns on/off')
	}

	mut dns_cmd := cli.Command{
		usage: '<name>'
		description: 'Manage dns records for publish tools'
		name: 'dns'
		execute: dns_execute
	}

	// PUBLISH
	// publish_exec := fn (cmd cli.Command) ? {
	// 	mut args := os.args.clone()
	// 	mut cfg := publisher_config.get()?
	// 	mut env := 'staging'

	// 	mut production := cmd.flags.get_bool('production') or { false }

	// 	mut updatepubtools := cmd.flags.get_bool('update_pubtools') or { false }
	// 	// mut update_digitaltwin := cmd.flags.get_bool('update_digitaltwin') or { false }
	// 	if production {
	// 		env = 'production'
	// 	}

	// 	mut prefix := cfg.publish.paths.publish + '/'

	// 	println('\n**********************')
	// 	println('Publishing to $env')
	// 	println('**********************')

	// 	mut ip := ''

	// 	if production {
	// 		ip = '104.131.122.247'
	// 	} else {
	// 		ip = '161.35.109.242'
	// 	}

	// 	args.delete(0)
	// 	args.delete(0)

	// 	mut idx := args.index('--production')
	// 	if idx != -1 {
	// 		args.delete(idx)
	// 	}

	// 	idx = args.index('--update_pubtools')
	// 	if idx != -1 {
	// 		args.delete(idx)
	// 	}

	// 	idx = args.index('--update_digitaltwin')
	// 	if idx != -1 {
	// 		args.delete(idx)
	// 	}

	// 	mut sync := []string{}

	// 	if updatepubtools {
	// 		println(' (*) updating publishtools')
	// 		process.execute_stdout('ssh root@$ip "publishtools update"') ?
	// 	}

	// 	mut configs := os.ls('.') or { panic(err) }
	// 	mut configsstr := ''
	// 	// name: config file name so we can later decides which configs will be synced according to what dirs will be synced from fs
	// 	mut configdict := map[string]string{}

	// 	mut websites := []string{}
	// 	mut wikis := []string{}

	// 	for item in configs {
	// 		if !item.ends_with('.json') || item in ['config.json', 'groups_a.json', 'nodejs.json'] {
	// 			continue
	// 		}

	// 		content := os.read_file(item) or { return error('Failed to load  config file $item') }
	// 		siteconf := json.decode(publisher_config.SiteConfig, content) or {
	// 			println(err)
	// 			return error('Failed to decode json for  config file $item')
	// 		}

	// 		configdict[siteconf.name] = item

	// 		// wikis
	// 		if siteconf.cat == publisher_config.SiteCat.wiki {
	// 			wikis << '$siteconf.name'
	// 		} else if siteconf.cat == publisher_config.SiteCat.web {
	// 			websites << '$siteconf.name'
	// 		}
	// 	}

	// 	mut skip_sites := false
	// 	mut skip_wikis := false

	// 	if 'wikis' in args {
	// 		for i in wikis {
	// 			sync << i
	// 		}
	// 		args.delete(args.index('wikis'))
	// 		skip_wikis = true
	// 	}

	// 	if 'sites' in args {
	// 		for i in websites {
	// 			sync << i
	// 		}

	// 		args.delete(args.index('sites'))
	// 		skip_sites = true
	// 	}

	// 	mut err := false
	// 	for arg in args {
	// 		if arg in websites && skip_sites {
	// 			continue
	// 		} else if arg in wikis && skip_wikis {
	// 			continue
	// 		} else {
	// 			if !(arg in websites) && !(arg in wikis) {
	// 				err = true
	// 				println(' (*) Skipping ($arg) name not found in wikis or websites')
	// 				continue
	// 			}
	// 			sync << arg
	// 		}
	// 	}

	// 	mut skipped := []string{}

	// 	if sync.len == 0 && err == false {
	// 		for i in wikis {
	// 			sync << i
	// 		}
	// 		for i in websites {
	// 			sync << i
	// 		}
	// 	}

	// 	mut syncstr := ''
	// 	mut publishedwikis := []string{}

	// 	mut tosync := []string{}

	// 	if sync.len > 0 {
	// 		for item in sync {
	// 			if item in wikis { // track published wikis regardless what
	// 				publishedwikis << item
	// 			}

	// 			if os.exists('$prefix$item') {
	// 				tosync << item
	// 				syncstr += '$prefix$item '
	// 			} else if os.exists('$prefix' + 'wiki_' + '$item') {
	// 				tosync << item
	// 				syncstr += '$prefix' + 'wiki_' + '$item '
	// 			} else {
	// 				skipped << item
	// 			}
	// 		}
	// 	}

	// 	if tosync.len > 0 {
	// 		println(' (*) syncing the following ....')
	// 		for item in tosync {
	// 			println('     (**) $item')
	// 		}
	// 	}

	// 	if skipped.len > 0 {
	// 		println(' (*) Skipping the  following [Not Found in filesystem] in $prefix')
	// 		for item in skipped {
	// 			println('     (**) $item')
	// 		}
	// 	}

	// 	/*
	// 	We don't need to force pull repos again on staging/production
	// 	we build from gitpod or DO machine
	// 	*/

	// 	// if publishedwikis.len > 0{
	// 	// 	println(' (*) Force pull these wikis on the remote machine')
	// 	// 	for item in publishedwikis{
	// 	// 		println('     (**) $item')
	// 	// 	}
	// 	// }

	// 	// force pull wikis (remote server may be running publishtools server)
	// 	mut command := ''
	// 	cmdprefix := 'publishtools pull --repo'
	// 	for wiki in publishedwikis {
	// 		command += ' $cmdprefix $wiki && '
	// 	}

	// 	command = command.trim_right(' &&')

	// 	if syncstr != '' || publishedwikis.len > 0 {
	// 		configs = []string{}

	// 		if syncstr != '' {
	// 			for item in syncstr.split(' ') {
	// 				mut item2 := item.trim(' ')
	// 				if item2 != '' {
	// 					item2 = item2.replace(prefix, '').trim(' ')
	// 					configs << configdict[item2]
	// 				}
	// 			}
	// 		}

	// 		if publishedwikis.len > 0 {
	// 			for item in publishedwikis {
	// 				item2 := item.trim(' ')

	// 				if item2 != '' {
	// 					if !(item2 in configs) {
	// 						configs << configdict[item2]
	// 					}
	// 				}
	// 			}
	// 		}

	// 		if configs.len > 0 {
	// 			print(' (*) uploading configuration files  to root@$ip:/root/.publisher/config\n')
	// 			for c in configs {
	// 				if c.trim(' ') == '' {
	// 					continue
	// 				}
	// 				println('     (**) $c')
	// 			}
	// 			configsstr = configs.join(' ')
	// 			process.execute_stdout('rsync --progress -ra --human-readable $configsstr root@$ip:/root/.publisher/config') ?
	// 		}
	// 	}

	// 	if syncstr != '' {
	// 		println(' (*) Rsyncing')
	// 		println(syncstr)
	// 		process.execute_stdout('rsync -v --stats --progress -ra --delete --human-readable $syncstr root@$ip:/root/.publisher/publish/') or {
	// 			println('************** WARNING ****************')
	// 			println('Could not rsync:')
	// 			println(err)
	// 		}
	// 	}

	// 	/*
	// 	We don't need to force pull repos again on staging/production
	// 	we build from gitpod or DO machine
	// 	*/
	// 	// if publishedwikis.len > 0{
	// 	// 	println(' (*) pull wikis on remote server')
	// 	// 	process.execute_stdout(command)?
	// 	// }

	// 	if syncstr != '' || publishedwikis.len > 0 {
	// 		println(' (*) updating static files')
	// 		process.execute_stdout('ssh root@$ip "cd ~/.publisher/config && publishtools staticfiles update"') ?

	// 		println(' (*) Restarting digitaltwin')
	// 		process.execute_stdout('ssh root@$ip "cd ~/.publisher/config && source ~/.bashrc && publishtools digitaltwin restart"') ?
	// 	}
	// }

	staticfilesupdate_execute := fn (cmd cli.Command) ? {
		mut args := os.args.clone()
		if args.len == 3 {
			if args[2] == 'update' {
				mut cfg := publisher_config.get()?
				cfg.update_staticfiles(true) ?
				return
			}
		}
		println('usage: publishtools cache update')
	}

	mut staticfilesupdate_cmd := cli.Command{
		usage: '<name>'
		description: 'Update staticfiles'
		name: 'staticfiles'
		execute: staticfilesupdate_execute
	}

	mut publish_cmd := cli.Command{
		name: 'publish'
		description: 'Publish websites/wikis to production/staging'
		usage: '
		Examples		
			publishtools publish wikis
			publish wikis only
			publishtools publish sites
			publish sites only
			publishtools publish wikis  www_threefold_farming	publish wikis and certain website
			publishtools publish --production wikis		  		publish wikis only but on production
		'
	}

	publish_cmd.add_flag(publish_prod_flag)
	publish_cmd.add_flag(update_publishtools_flag)

	// MAIN
	mut main_cmd := cli.Command{
		name: 'installer'
		commands: [install_cmd, run_cmd, build_cmd, list_cmd, develop_cmd, pull_cmd, commit_cmd,discard_cmd,
			push_cmd, pushcommit_cmd, edit_cmd, update_cmd, version_cmd, removechangese_cmd, dns_cmd,
			flatten_cmd, publish_cmd, staticfilesupdate_cmd]
		description: '

        Publishing Tool Installer
        This tool helps you to install & run wiki & websites

        '
	}

	// gittools.get() or {panic(err)}
	// publisher_config.get() or {panic(err)}
	// println(22)

	main_cmd.setup()
	main_cmd.parse(os.args)

	// println(' - OK')
}
