module config
import gittools

pub fn config() ConfigData {

	//get publisher, check for all wiki's
	mut gt := gittools.new("~/codesync") or {panic ("cannot load gittools:$err")}
	
	//will only pull if it does not exists
	_ := gt.repo_get_from_url("https://github.com/threefoldtech/info_tftech") or {panic ("cannot load info_tftech:$err")}

	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/www_threefold_cloud") or {panic ("cannot load repo:$err")}
	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/www_threefold_farming") or {panic ("cannot load repo:\n$err")}
	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/www_threefold_twin") or {panic ("cannot load repo:\n$err")}
	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/www_vdc") or {panic ("cannot load repo:\n$err")}
	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/www_tfnow") or {panic ("cannot load repo:\n$err")}
	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/www_conscious_internet") or {panic ("cannot load repo:\n$err")}
	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/info_foundation") or {panic ("cannot load repo:$err")}
	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/info_tfgrid_sdk") or {panic ("cannot load repo:$err")}
	_ := gt.repo_get_from_url("https://github.com/threefoldfoundation/legal") or {panic ("cannot load repo:\n$err")}

	mut configdata := ConfigData{root:"~/codesync"}

	return configdata

}

