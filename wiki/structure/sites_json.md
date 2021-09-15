# how to use a site.json

put a json file in a directory and launching
`publishtools flatten` or any other command from that directory

It will use this config file only.

some specials

- if pull = true, will at every start pull info in, if changes will fail
- if reset then will remove all changes, ideal to run as automated system, BE CAREFUL
- branch if used, will force the right branch when doing a pull, if it can't will fail.

example

```json
[
  {
    "name": "info_threefold",
    "url": "https://github.com/threefoldfoundation/info_threefold",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 0,
    "shortname": "threefold",
    "domains": ["info.threefold.io", "wiki.threefold.io"],
    "descr": "wiki for foundation, collaborate, what if farmings, tokens",
    "circles": [],
    "acl": []
  },
  {
    "name": "info_tag",
    "url": "https://github.com/takeactionglobal/info_tag",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 0,
    "shortname": "tag",
    "domains": ["info.takeactionglobal.org"],
    "descr": "wiki for TAG.",
    "circles": [],
    "acl": []
  },
  {
    "name": "info_sdk",
    "url": "https://github.com/threefoldfoundation/info_sdk",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 0,
    "shortname": "sdk",
    "domains": ["sdk.threefold.io"],
    "descr": "for IAC, devops, how to do Infrastruture As Code, 3bot, Ansible, tfgrid-sdk, ...",
    "circles": [],
    "acl": []
  },
  {
    "name": "info_legal",
    "url": "https://github.com/threefoldfoundation/info_legal",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 0,
    "shortname": "legal",
    "domains": [
      "legal.threefold.io",
      "legal-info.threefold.io",
      "legal-wiki.threefold.io"
    ],
    "descr": "",
    "circles": [],
    "acl": []
  },
  {
    "name": "info_cloud",
    "url": "https://github.com/threefoldfoundation/info_cloud",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 0,
    "shortname": "cloud",
    "domains": ["cloud-info.threefold.io", "cloud-wiki.threefold.io"],
    "descr": "how to use the cloud for deploying apps: evdc, kubernetes, planetary fs, ... + marketplace solutions ",
    "circles": [],
    "acl": []
  },
  {
    "name": "info_tftech",
    "url": "https://github.com/threefoldtech/info_tftech",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 0,
    "shortname": "tftech",
    "domains": ["info.threefold.tech"],
    "descr": "",
    "circles": [],
    "acl": []
  },
  {
    "name": "info_digitalself",
    "url": "https://github.com/threefoldfoundation/info_digitalself.git",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 0,
    "shortname": "twin",
    "domains": ["info.mydigitaltwin.io", "wiki.mydigitaltwin.io"],
    "descr": "",
    "circles": [],
    "acl": []
  },
  {
    "name": "info_bettertoken",
    "url": "https://github.com/BetterToken/info_bettertoken.git",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 0,
    "shortname": "bt",
    "domains": ["bt-info.threefold.io"],
    "descr": "",
    "circles": [],
    "acl": []
  },
  {
    "name": "info_publishtools",
    "url": "https://github.com/freeflowuniverse/crystaltools",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 0,
    "shortname": "pubtools",
    "domains": ["publtools.threefold.io"],
    "descr": "documentation for publishting tools",
    "circles": [],
    "acl": []
  }
]
```

> for a more complete example see [sites_json_long](sites_json_long)
