module builder

pub struct DB {
	node        Node
mut:
	environment map[string]string
}

// get the node instance
pub fn (mut node Node) db_new() DB {
	mut db := DB{
		node: node
	}
	db.environment_load()
	// make sure the db path exists
	db.node.executor.exec('mkdir -p ${db.environment['HOME']}/.config/builder')
	return db
}

// get the path of the config db
fn (mut db DB) db_key_path_get(key string) string {
	return db.environment['HOME'] + '/.config/builder/${key}.json'
}

// get remote environment arguments in memory
fn (mut db DB) environment_load() ? {
	db.environment = db.node.executor.environ_get() or { return error('can not load env') }
}

// return info from the db
pub fn (mut db DB) get(key string) ?string {
	fpath := db.db_key_path_get(key)
	return db.node.executor.file_read(fpath)
	// conf2 := json.decode(Node, statedata) or {
	//     panic('Failed to parse json for $fpath.\n Data was $statedata')
	// }
}

// return info from the db
pub fn (mut db DB) save(key string, val string) ? {
	fpath := db.db_key_path_get(key)
	db.node.executor.file_write(fpath, val)
}

// use * to remove all
// use prefix* to search over all entries whcih start with the prefix
pub fn (mut db DB) reset(key string) ? {
	if key == '*' {
		db.node.executor.exec(' rm -rf ${db.environment['HOME']}/.config/builder && mkdir ${db.environment['HOME']}/.config/builder')
	} else if key.ends_with('*') {
		// use find to walk over keys who start with the key, remove them all, can be done in one find command !
		// TODO: implement & test
	} else {
		fpath := db.db_key_path_get(key)
		db.node.executor.remove(fpath)
	}
}
