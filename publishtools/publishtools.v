module main

import io.util
import json
import despiegk.crystallib.installers
import os
import despiegk.crystallib.process
import cli
import despiegk.crystallib.publisher_core
import despiegk.crystallib.publisher_config
// import despiegk.crystallib.gittools

fn flatten(mut publ publisher_core.Publisher) bool {
	publ.flatten() or { return false }
	return true
}

fn resolvepublisheditems(items string, prefix string, path string) ?string{
	txt := os.read_file(path) ?
	mut remotconig := json.decode([]publisher_config.SiteConfig, txt) ?
	mut remotesites := map[string]publisher_config.SiteConfig{}
	mut remotewikis := map[string]publisher_config.SiteConfig{}

	for item in remotconig{
		if item.cat == publisher_config.SiteCat.wiki{
			remotewikis['wiki_$item.name'] = item
		}else{
			remotesites[item.name] = item
		}
	}


	mut splitted := items.trim(' ').split(" ")
	mut tosync := []string{}
	for item in splitted{
		tosync << item
	}
	
	mut cfg := publisher_config.get() ?

	mut allsites :=  map[string]publisher_config.SiteConfig{}
	mut allwikis :=  map[string]publisher_config.SiteConfig{}
	
	mut res :=  map[string]publisher_config.SiteConfig{}

	for site in cfg.sites{
		if site.cat == publisher_config.SiteCat.wiki{
			allwikis['wiki_$site.name'] = site
			
		}else if site.cat == publisher_config.SiteCat.web{
			allsites[site.name] = site
		}
	}

	mut configsitesall := false
	mut configwikisall := false

	if tosync.contains('*'){
		for k, v in allsites{
			res[k] = v
		}

		for k, v in allwikis{
			res[k] = v
		}
		configsitesall = true
		configwikisall = true

	}else {
		if tosync.contains('wiki_*'){
			tosync.delete(tosync.index('wiki_*'))
			for k, v in allwikis{
				res[k] = v
			}
			configwikisall = true
		}
		
		if tosync.contains('www_*'){
			tosync.delete(tosync.index('www_*'))
			for k, v in allsites{
				res[k] = v
			}
			configsitesall = true
		}

		for item in tosync{
			if ! (item in allsites) && ! (item in allwikis){
				panic('$item is not found in config file')
			}
			if !(item in res){

				if item in allsites{
					res[item] = allsites[item]
				}else{
					res[item] = allwikis[item]
				}
			}
		}
	}

	mut result := ''
	println('Syncing')
	for item, _ in res{
		result += prefix + item
		println('\t' +  prefix + item)
		result += ' '
	}

	// we publish all wikis
	if configwikisall{
		for k, _ in remotewikis{
			if k.starts_with('wiki_'){
				remotewikis.delete(k)
			}
		}

		for k, v in res{
			if k.starts_with('wiki_'){
				remotewikis[k] = v
			}
		}
	}

	// we publish all sites
	if configsitesall{
		for k, _ in remotewikis{
			if !(k.starts_with('wiki_')){
				remotesites.delete(k)
			}
		}

		for k, v in res{
			if !(k.starts_with('wiki_')){
				remotesites[k] = v
			}
		}
	}

	for k, v in res{
		if k.starts_with('wiki_'){
			remotewikis[k] = v
		}else{
			remotesites[k] = v
		}
	}

	mut out := []publisher_config.SiteConfig{}
	
	for _, v in remotesites{
		out << v
	}
	for _, v in remotewikis{
		out << v
	}

	println("rewriting config file @$path")
	os.write_file(path, json.encode_pretty(out))?
	
	return result.trim(' ')
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
		abbrev: 'r'
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

	path_prefix_flag := cli.Flag{
		name: 'pathprefix'
		abbrev: 'p'
		description: 'Build website(s) with alias prefix'
		flag: cli.FlagType.bool
	}

	development_flag := cli.Flag{
		name: 'development'
		abbrev: 'd'
		description: 'Run digitaltwin in dev mode locally (no pm2)'
		flag: cli.FlagType.bool
	}

	publish_prod_flag := cli.Flag{
		name: 'production'
		abbrev: 'p'
		description: 'publish production'
		flag: cli.FlagType.bool
	}

	install_exec := fn (cmd cli.Command) ? {
		installers.main(cmd) ?
	}

	mut install_cmd := cli.Command{
		name: 'install'
		execute: install_exec
	}

	update_publishtools := cli.Flag{
		name: 'update_pubtools'
		abbrev: 'u'
		description: 'update publishtools'
		flag: cli.FlagType.bool
	}

	update_digitaltwin := cli.Flag{
		name: 'update_digitaltwin'
		abbrev: 't'
		description: 'update digitaltwin'
		flag: cli.FlagType.bool
	}

	install_cmd.add_flag(pullflag)
	install_cmd.add_flag(resetflag)
	install_cmd.add_flag(cleanflag)

	// DEVELOP
	develop_exec := fn (cmd cli.Command) ? {
		webrepo := cmd.flags.get_string('repo') or { '' }
		mut cfg := publisher_config.get() ?
		println(cfg)
		panic("ssss")
		// mut gt := gittools.new(cfg.publish.paths.code)?
		// process.execute_stdout('rm -rf $cfg.publish.paths.codewiki/*') ?
		
		// wikis := cfg.sites.filter(it.cat == publisher_config.SiteCat.wiki)
		// mut symlinks := ''

		// for wiki in wikis{
		// 	mut repo :=  gt.repo_get(name : wiki.name)?
		// 	symlinks += repo.path 
		// 	symlinks += ' '
		// }

		// process.execute_stdout('ln -s $symlinks $cfg.publish.paths.codewiki/') ?

		if webrepo == '' {
			println(' - develop for wikis')
			// installers.sites_download(cmd, false) ?
			mut publ := publisher_core.new(&cfg)?
			publisher_core.webserver_run(mut &publ) ?
		} else {
			println(' - develop website: $webrepo')
			installers.website_develop(&cmd, mut &cfg) ?
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
		installers.sites_download(cmd, false) ?
		cfg := publisher_config.get() ?
		println(cfg)
		panic("s")
		mut publ := publisher_core.new(cfg.publish.paths.code)?
		publ.check()?
		publ.flatten() ?
		publisher_core.webserver_run(publ, cfg)
	}
	mut run_cmd := cli.Command{
		description: 'run all websites & wikis, they need to be build first'
		name: 'run'
		execute: run_exec
		required_args: 0
	}

	// FLATTEN
	flatten_exec := fn (cmd cli.Command) ? {
		installers.sites_download(cmd, false) ?
		cfg := publisher_config.get() ?
		mut publ := publisher_core.new(cfg.publish.paths.code) ?
		publ.check() ?
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
		installers.sites_download(cmd, true) ?
		cfg := publisher_config.get() ?
		mut publ := publisher_core.new(cfg.publish.paths.code) ?
		publ.check()?

		installers.website_build(&cmd) ?
	}
	mut build_cmd := cli.Command{
		name: 'build'
		usage: 'specify name of website or wiki to build'
		execute: build_exec
		required_args: 0
	}
	build_cmd.add_flag(repoflag)
	build_cmd.add_flag(path_prefix_flag)

	// LIST
	list_exec := fn (cmd cli.Command) ? {
		installers.sites_download(&cmd, false) ?
		installers.sites_list(&cmd) ?
	}
	mut list_cmd := cli.Command{
		name: 'list'
		execute: list_exec
	}

	// PULL
	pull_exec := fn (cmd cli.Command) ? {
		installers.sites_download(cmd, false) ?
		installers.sites_pull(&cmd) ?
	}
	mut pull_cmd := cli.Command{
		name: 'pull'
		execute: pull_exec
	}
	pull_cmd.add_flag(resetflag)
	pull_cmd.add_flag(repoflag)

	// EDIT
	edit_exec := fn (cmd cli.Command) ? {
		installers.site_edit(&cmd) ?
	}
	mut edit_cmd := cli.Command{
		name: 'edit'
		execute: edit_exec
	}
	edit_cmd.add_flag(repoflag)

	// VERSION
	version_exec := fn (cmd cli.Command) ? {
		println('1.0.20')
	}
	mut version_cmd := cli.Command{
		name: 'version'
		execute: version_exec
	}

	// pushcommit
	pushcommit_exec := fn (cmd cli.Command) ? {
		installers.sites_download(&cmd, false) ?
		installers.sites_pushcommit(&cmd) ?
	}
	mut pushcommit_cmd := cli.Command{
		name: 'pushcommit'
		execute: pushcommit_exec
	}
	pushcommit_cmd.add_flag(messageflag)
	pushcommit_cmd.add_flag(repoflag)

	// commit
	commit_exec := fn (cmd cli.Command) ? {
		installers.sites_download(&cmd, false) ?
		installers.sites_commit(&cmd) ?
	}
	mut commit_cmd := cli.Command{
		name: 'commit'
		execute: commit_exec
	}
	commit_cmd.add_flag(messageflag)
	commit_cmd.add_flag(repoflag)

	// PUSH
	push_exec := fn (cmd cli.Command) ? {
		installers.sites_download(&cmd, false) ?
		installers.sites_push(&cmd) ?
	}
	mut push_cmd := cli.Command{
		name: 'push'
		execute: push_exec
	}
	push_cmd.add_flag(resetflag)
	push_cmd.add_flag(repoflag)

	// DIGITAL TWIN
	twin_exec := fn (cmd cli.Command) ? {
		mut args := os.args.clone()
		mut install := false
		mut update := false
		mut start := false
		mut restart := false
		mut reload := false
		mut stop := false
		mut status := false
		mut logs := false

		for arg in args {
			if arg == 'install' {
				install = true
			} else if arg == 'update' {
				update = true
			} else if arg == 'reload' {
				reload = true
			} else if arg == 'restart' {
				restart = true
			} else if arg == 'start' {
				start = true
			} else if arg == 'stop' {
				stop = true
			} else if arg == 'status' {
				status = true
			} else if arg == 'logs' {
				logs = true
			}
		}

		mut development := cmd.flags.get_bool('development') or { false }
		mut production := !development

		mut cfg := installers.config_get(cmd) ?

		if install {
			installers.digitaltwin_install(mut &cfg, false) or {
				panic(' ** ERROR: cannot install digital twin. Error was:\n$err')
			}
		} else if update {
			installers.digitaltwin_install(mut &cfg, true) or {
				panic(' ** ERROR: cannot update digital twin. Error was:\n$err')
			}
		} else if start {
			installers.digitaltwin_start(mut &cfg, production, false) or {
				panic(' ** ERROR: cannot start digital twin. Error was:\n$err')
			}
		} else if restart {
			installers.digitaltwin_restart(mut &cfg, production) or {
				panic(' ** ERROR: cannot restart digital twin. Error was:\n$err')
			}
		} else if reload {
			installers.digitaltwin_reload(mut &cfg, production) or {
				panic(' ** ERROR: cannot reload digital twin. Error was:\n$err')
			}
		} else if stop {
			installers.digitaltwin_stop(mut &cfg, production) or {
				panic(' ** ERROR: cannot stop digital twin. Error was:\n$err')
			}
		} else if status {
			installers.digitaltwin_status(mut &cfg, production) or {
				panic(' ** ERROR: cannot get status for digital twin. Error was:\n$err')
			}
		} else if logs {
			installers.digitaltwin_logs(mut &cfg, production) or {
				panic(' ** ERROR: cannot get logs for digital twin. Error was:\n$err')
			}
		} else {
			println('usage: publishtools digitaltwin --help')
		}
	}
	mut twin_cmd := cli.Command{
		name: 'digitaltwin'
		usage: '<start|restart|stop|reload|update|status|logs|install>'
		execute: twin_exec
	}

	twin_cmd.add_flag(development_flag)

	// UPDATE
	update_exec := fn (cmd cli.Command) ? {
		installers.publishtools_update() ?
		installers.sites_download(&cmd, false) ?
	}
	mut update_cmd := cli.Command{
		name: 'update'
		usage: 'update the tool'
		execute: update_exec
		required_args: 0
	}

	// REMOVE CHANGES
	removechanges_exec := fn (cmd cli.Command) ? {
		installers.sites_download(cmd, false) ?
		installers.sites_removechanges(&cmd) ?
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
				publisher_core.dns_off(true)
				return
			} else if args[2] == 'on' {
				publisher_core.dns_on(true)
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

	// publish
	publish_exec := fn (cmd cli.Command) ? {
		mut args := os.args.clone()
		mut cfg := publisher_config.get() ?

		mut env := 'staging'

		mut production := cmd.flags.get_bool('production') or { false }
		
		mut updatepubtools := cmd.flags.get_bool('update_pubtools') or { false }
		mut update_digitaltwin := cmd.flags.get_bool('update_digitaltwin') or { false }
		if production {
			env = 'production'
		}

	
		mut ip := ''

		if production {
			ip = '104.131.122.247'
		} else {
			ip = '161.35.109.242'
		}

		args.delete(0)
		args.delete(0)

		mut idx := args.index('--production')
		if idx != -1 {
			args.delete(idx)
		}

		idx =args.index('--update_pubtools')
		if idx != -1 {
			args.delete(idx)
		}

		idx =args.index('--update_digitaltwin')
		if idx != -1 {
			args.delete(idx)
		}

		mut publ := publisher_core.new(cfg.publish.paths.code) ?
		publ.check()?
		publ.flatten() ?

		mut sync := ''
		mut prefix := cfg.publish.paths.publish + '/'
		mut skip_sites := false
		mut skip_wikis := false

		if 'wikis' in args {
			sync += 'wiki_* '
			args.delete(args.index('wikis'))
			skip_wikis = true
		}

		if 'sites' in args {
			sync += 'www_* '
			args.delete(args.index('sites'))
			skip_sites = true
		}

		for arg in args {
			if arg.starts_with('www') && skip_sites {
				continue
			} else if arg.starts_with('wiki') && skip_wikis {
				continue
			} else {
				sync += arg + ''
			}
		}

		if sync == '' {
			sync = '*'
		}

		//TODO: THIS IS NOT WELL DONE, THIS SHOULD NOT BE HERE BUT IN THE MODULES SOMEWHERE

		// download remote config
		mut _, mut configpath := util.temp_file({})?
		println('Downloading remote config root@$ip:/root/.publisher/containerhost/publisher/sites.json to $configpath')
		cmd2 := 'rsync --progress --human-readable root@$ip:/root/.publisher/containerhost/publisher/sites.json $configpath'
		process.execute_stdout(cmd2)?
		println('Syncing to $env ($ip)')
		
		sync = resolvepublisheditems(sync, prefix, configpath)?
		
		if updatepubtools{
			println('updating publishtools')
			process.execute_stdout('ssh root@$ip "docker exec -i web publishtools update"') ?
		}

		println('uploading  new configuration file $configpath to root@$ip:/root/.publisher/containerhost/publisher/sites.json')
		process.execute_stdout('rsync --progress -ra --human-readable $configpath root@$ip:/root/.publisher/containerhost/publisher/sites.json') ?

		println('updating static files')
		process.execute_stdout('ssh root@$ip "docker exec -i web publishtools staticfiles update"') ?

		cmd3 := 'rsync -v --stats --progress -ra --delete --human-readable $sync root@$ip:/root/.publisher/containerhost/publisher/publish/'
		process.execute_stdout(cmd3) or {
			println("************** WARNING ****************")
			println("Could not rsync:")
			println(cmd3)
		}	

		if update_digitaltwin{
			println('updating digitaltwin server\n')
			process.execute_stdout('ssh root@$ip "docker exec -i web publishtools digitaltwin update"') ?
			process.execute_stdout('ssh root@$ip "docker exec -i web publishtools digitaltwin restart"') ?
		}else{
			println('reloading server\n')
			process.execute_stdout('ssh root@$ip "docker exec -i web publishtools digitaltwin reload"') ?
		}
	}

	staticfilesupdate_exrcute := fn (cmd cli.Command) ? {
		mut args := os.args.clone()
		if args.len == 3 {
			if args[2] == 'update' {
				mut cfg := publisher_config.get() ?
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
		execute: staticfilesupdate_exrcute
	}

	mut publis_cmd := cli.Command{
		name: 'publish'
		description: 'Publish websites/wikis to production/staging'
		usage: '\n\nExamples\npublishtools publish wikis  \t\t  		 publish wikis only
publishtools publish sites  \t\t  		 publish sites only
publishtools publish wikis  www_threefold_farming\t publish wikis and certain website
publishtools publish --production wikis  \t  		 publish wikis only but on production'
		execute: publish_exec
	}

	publis_cmd.add_flag(publish_prod_flag)
	publis_cmd.add_flag(update_publishtools)
	publis_cmd.add_flag(update_digitaltwin)


	// MAIN
	mut main_cmd := cli.Command{
		name: 'installer'
		commands: [install_cmd, run_cmd, build_cmd, list_cmd, develop_cmd, twin_cmd, pull_cmd,
			commit_cmd, push_cmd, pushcommit_cmd, edit_cmd, update_cmd, version_cmd, removechangese_cmd,
			dns_cmd, flatten_cmd, publis_cmd, staticfilesupdate_cmd]
		description: '

        Publishing Tool Installer
        This tool helps you to install & run wiki & websites

        '
	}

	main_cmd.setup()
	main_cmd.parse(os.args)

	// println(' - OK')
}
