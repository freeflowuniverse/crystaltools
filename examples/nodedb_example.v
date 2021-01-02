import os
import rand

import builder

fn test_nodedb(args builder.DBArguments){
	path := "$os.home_dir()/.config/$args.db_dirname"
	println("creating test db in $path")
	os.rmdir(path)

	mut db := builder.db_new(args) or {panic(err)}


	assert os.exists(path)
	// get non existing key
	mut failed := false
	db.get("random_key") or {failed = true}

	if !failed{
		panic("should have failde to get non existing key")
	}

	// save
	db.save("key1", '{"k1": "val1"}')
	val := db.get("key1") or {panic(err)}
	assert  val == '{"k1": "val1"}'

	db.delete("key1") or {panic(err)}
	
	failed = false
	db.get("key1") or {failed = true}

	if !failed{
		panic("should have failde to get non existing key")
	}

	db.save("key1", '{"k1": "val1"}')
	db.save("key2", '{"k1": "val1"}')
	db.save("key3", '{"k1": "val1"}')

	db.get("key1") or {panic(err)}
	db.get("key2") or {panic(err)}
	db.get("key3") or {panic(err)}

	

	mut res := os.ls(path) or {panic(err)}
	assert res.len == 3

	db.reset()

	res = os.ls(path) or {panic(err)}
	assert res.len == 0

	db.save("key1", '{"k1": "val1"}')
	db.save("key2", '{"k1": "val1"}')
	db.save("key3", '{"k1": "val1"}')
	db.save("1", '{"k1": "val1"}')
	db.save("2", '{"k1": "val1"}')
	db.save("3", '{"k1": "val1"}')
	db.save("1key", '{"k1": "val1"}')
	db.save("2key", '{"k1": "val1"}')
	db.save("3key", '{"k1": "val1"}')

	res = os.ls(path) or {panic(err)}
	assert res.len == 9

	db.delete("key*")
	res = os.ls(path) or {panic(err)}
	assert res.len == 6

	assert '1.json' in res
	assert '2.json' in res
	assert '3.json' in res
	assert '1key.json' in res
	assert '2key.json' in res
	assert '3key.json' in res

	db.delete("*key")
	res = os.ls(path) or {panic(err)}
	assert res.len == 3
	assert '1.json' in res
	assert '2.json' in res
	assert '3.json' in res
	
	// clean after test
	println("removing test db in $path")
	os.rmdir(path)
}	


fn local(){

	mut db_dirname := rand.uuid_v4()

	mut args := builder.DBArguments{
		node_args: builder.NodeArguments{} // local
		db_dirname: db_dirname
	} 
	test_nodedb(args)
}

fn remote(){
	mut db_dirname := rand.uuid_v4()
	mut args := builder.DBArguments{
		node_args: builder.NodeArguments{ipaddr:"104.236.53.191:22",name:"myremoteserver", user: "root"} // local
		db_dirname: db_dirname
	} 

	test_nodedb(args)
}

fn main(){
	
	local()
	// remote()
}