module gittools
import json

fn test_url1() {
	url := "https://github.com/vlang/v/blob/master/doc/docs.md#maps"
	obj := addr_get_from_url(url)


	tocompare := GitAddr{
		provider: 'github.com'
		account: 'vlang'
		repo: 'v'
		path: 'doc/docs.md'
		branch: 'master'
		anker: 'maps'
	}	

	assert json.encode(obj)== json.encode(tocompare)
}

fn test_url2() {
	url := "https://github.com/vlang/v/blob/master/doc/docs.md"
	obj := addr_get_from_url(url)


	tocompare := GitAddr{
		provider: 'github.com'
		account: 'vlang'
		repo: 'v'
		path: 'doc/docs.md'
		branch: 'master'
	}	

	assert json.encode(obj)== json.encode(tocompare)
}

fn test_url3() {
	url := "https://github.com/vlang/v/blob/master/"
	obj := addr_get_from_url(url)

	tocompare := GitAddr{
		provider: 'github.com'
		account: 'vlang'
		repo: 'v'
		path: ''
		branch: 'master'
	}	

	assert json.encode(obj)== json.encode(tocompare)

}

fn test_url4() {
	url := "https://github.com/vlang/v"
	obj := addr_get_from_url(url)

	tocompare := GitAddr{
		provider: 'github.com'
		account: 'vlang'
		repo: 'v'
		path: ''
		branch: ''
	}	

	assert json.encode(obj)== json.encode(tocompare)

}

fn test_url4b() {
	url := "https://github.com/vlang/v.git"
	obj := addr_get_from_url(url)

	tocompare := GitAddr{
		provider: 'github.com'
		account: 'vlang'
		repo: 'v'
		path: ''
		branch: ''
	}	

	assert json.encode(obj)== json.encode(tocompare)

}

fn test_url4c() {
	url := "http://github.com/vlang/v.git"
	obj := addr_get_from_url(url)

	tocompare := GitAddr{
		provider: 'github.com'
		account: 'vlang'
		repo: 'v'
		path: ''
		branch: ''
	}	

	assert json.encode(obj)== json.encode(tocompare)

}



fn test_url5() {
	url := "git@github.com:vlang/v.git"
	obj := addr_get_from_url(url)

	tocompare := GitAddr{
		provider: 'github.com'
		account: 'vlang'
		repo: 'v'
		path: ''
		branch: ''
	}	

	assert json.encode(obj)== json.encode(tocompare)

}

fn test_url6() {
	url := "github.com:vlang/v.git"
	obj := addr_get_from_url(url)

	tocompare := GitAddr{
		provider: 'github.com'
		account: 'vlang'
		repo: 'v'
		path: ''
		branch: ''
	}	

	assert json.encode(obj)== json.encode(tocompare)

}


fn test_url7() {
	url := "github.com:vlang/v"
	obj := addr_get_from_url(url)

	tocompare := GitAddr{
		provider: 'github.com'
		account: 'vlang'
		repo: 'v'
		path: ''
		branch: ''
	}	

	assert json.encode(obj)== json.encode(tocompare)

}

fn test_path1() {

	addr := addr_get_from_url("https://github.com/crystaluniverse/crystaltools")
	r := repo_get(addr)
	r.pull()

	path := "~/code/github/crystaluniverse/crystaltools"
	obj := addr_get_from_path(path)

	tocompare := GitAddr{
		provider: 'github.com'
		account: 'crystaluniverse'
		repo: 'crystaltools'
		path: ''
		branch: ''
	}		

	assert json.encode(obj)== json.encode(tocompare)

}