module main

import os
import flag

import freeflowuniverse.crystallib.taigaexports

struct Args {
    url string
    username string
    password string
    project_id int
    project_slug string
}

fn (args Args) is_valid() bool {
    return args.url.len > 0 &&
           args.username.len > 0 &&
           args.password.len > 0 &&
           args.project_id > 0 &&
           args.project_slug.len > 0
}

fn parse_flags(mut fp flag.FlagParser) ?Args {
    args := Args{
        url: fp.string('url', `l`, 'https://circles.threefold.me', 'taiga instance URL. defaults to https://circles.threefold.me')
        username: fp.string('username', `u`, '', 'taiga user name'),
        password: fp.string('password', `p`, '', 'taiga password'),
        project_id: fp.int('id', 0, 0, 'project id'),
        project_slug: fp.string('slug', `s`, '', 'project slug')
    }

    fp.finalize()?

    if args.is_valid() {
        return args
    }

    return error("missing arguments")
}

fn export(args Args) {
    url := args.url
	mut exporter := taigaexports.new_from_credentials(url, args.username, args.password) or {
		println("cannot get an exporter for $url")
		panic(err)
	}

    // 265, 'despiegk-product_publisher'
	result := exporter.export_project(args.project_id, args.project_slug) or {
		println("error while exporting project of $args.project_id:$args.project_slug")
		panic(err)
	}

	println(result)
}

fn main() {
    mut fp := flag.new_flag_parser(os.args)
    fp.application('export_project')
    fp.version('v0.1')
    fp.limit_free_args(0, 0)? // comment this, if you expect arbitrary texts after the options
    fp.description('A tool to test full taiga project export api')
    fp.skip_executable()

    args := parse_flags(mut fp) or {
        eprintln('$err, see usage...')
        println(fp.usage())
        return
    }

    export(args)
}
