module helpers

import os


pub fn list_repos() map[string]map[string]string{
	mut path := "~/code/github/".replace("~", os.home_dir())
	mut organizations := os.ls(path) or {[]}
	mut res :=  map[string]map[string]string

	for org in organizations{
		mut repos := os.ls(os.join_path(path, org)) or {[]}
		for repo in repos{
			mut name := repo
			if ! repo.starts_with("info") && repo != "legal"{
				continue
			}
			if repo == "info_foundation"{
				name = "wiki"
			}
			res[name] =  {
				"path" : os.join_path(path, org, repo, "src")
			}
		}
	}
	return res
}