# Site Security

```json
[{
		"name":	"www_threefold_io",
		"url":	"https://github.com/threefoldfoundation/www_threefold_io",
		"branch":	"",
		"pull":	false,
		"reset":	false,
		"cat":	2,
		"shortname":	"threefold",

		"domains":	["www.threefold.io", "www.threefold.me", "threefold.me", "new.threefold.io", "staging.threefold.io", "threefold.io"],
		"descr":	"is our entry point for everyone, redirect to the detailed websites underneith.",
		"groups":	[{
				"name":	"tf1",
				"members_users":	["kristof", "adnan", "rob"],
				"members_groups":	[]
			}, {
				"name":	"tf2",
				"members_users":	["polleke"],
				"members_groups":	["tf1"]
			}],
		"acl":	[]
	}, {
		"name":	"www_threefold_cloud",
		"url":	"https://github.com/threefoldfoundation/www_threefold_cloud",
		"branch":	"",
		"pull":	false,
		"reset":	false,
		"cat":	2,
		"shortname":	"cloud",

		"domains":	["cloud.threefold.io", "cloud.threefold.me"],
		"descr":	"for people looking to deploy solutions on top of a cloud, alternative to e.g. digital ocean",
		"groups":	[],
		"acl":	[{
				"groups":	["tf2"],
				"users":	["polleke2"],
				"rights":	"R",
				"secrets":	["1234", "5678"]
			}]
	},...
```

- see how curckes can be defined
- groups can be parts of other groups
- when secrets used it will have same rights as acl
- rights for now always R (means Read)
- if acl used then only access when rights R specified
