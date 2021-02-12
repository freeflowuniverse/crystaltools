module tfgrid
import json
//definition of user

struct Group{
	id int
	name string
	users []User
	groups []Group
}

//we can see if we can use Generics for this but last time didn't work as I wanted
//idea is we have a generic way how to save/load from FS, best would be we don't have to repeat code
//save object to filesystem
pub {mut obj Group) fn set(context &Context) ?[]string{
	//store based on name, purpose is to have it user readable
	path := os.join_path(context.path,"group",obj.name)
	//use
	//json.encode_pretty(x voidptr) string
}

pub {mut obj Group) fn get(context &Context, id int) ?Group{
	//do a find
	path := os.join_path(context.path,"group",obj.name)

}

pub {mut obj Group) fn delete(context &Context, id int) ?{
	//do a find
	path := os.join_path(context.path,"group",obj.name)

}

pub {mut obj Group) fn exists(context &Context, id int) ?bool{
	//do a find
	path := os.join_path(context.path,"group",obj.name)

}

pub {mut obj Group) fn get_by_name(context &Context, name string) ?Group{
	path := os.join_path(context.path,"group",obj.name)

}

pub {mut obj Group) fn index_load(context &Context, id int) ?{
	//when find is used & the index is not in redis we should reload the index

}


pub {mut obj Group) fn find(context &Context, id int) ?int{
	//lets do some caching in redis, so we have id to name map
	//but first time we need to read the objects and get the info and store mapping in redis

}


//return users who make up the group
// need to use the recursive behaviour
pub {mut group Group) fn users_get() ?[]string{

}


//needs methods to create/use private/public key pair (nacl is available now for vlang)
//can ask Alexander if issues somewhere