//example from https://github.com/vlang/v/blob/master/doc/docs.md#generics trying to get it to work

struct User {
	tel int
	priority int
}


struct Post{
	message string
	priority int
}



struct Repo<T> {
    db DB
}

fn new_repo<T>(db DB) Repo<T> {
    return Repo<T>{db: db}
}

// This is a generic function. V will generate it for every type it's used with.
fn (r Repo<T>) find_by_id(id int) ?T {
    table_name := T.name // in this example getting the name of the type gives us the table name
	println(table_name)
    return r.db.query_by_id(id,table_name)
	// return r.db.query_by_id<T>(id,table_name)  //was this not sure this is correct?

	//HOW now to do something usefull with the data of User & Post
}

struct DB{

}

fn (mut e DB) query_by_id(i int, table_name string) string {
	return "test:$i:$table_name"
}


fn new_db(){
	return DB{}
}

db := new_db()
users_repo := new_repo<User>(db) // returns Repo<User>
posts_repo := new_repo<Post>(db) // returns Repo<Post>
user := users_repo.find_by_id(1)
post := posts_repo.find_by_id(1)