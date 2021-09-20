# more complete example

```json
[
  {
    "name": "www_threefold_io",
    "url": "https://github.com/threefoldfoundation/www_threefold_io",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 2,
    "shortname": "threefold",

    "domains": [
      "www.threefold.io",
      "www.threefold.me",
      "threefold.me",
      "new.threefold.io",
      "staging.threefold.io",
      "threefold.io"
    ],
    "descr": "is our entry point for everyone, redirect to the detailed websites underneith.",
    "groups": [
      {
        "name": "tf1",
        "members_users": ["kristof", "adnan", "rob"],
        "members_groups": []
      },
      {
        "name": "tf2",
        "members_users": ["polleke"],
        "members_groups": ["tf1"]
      }
    ],
    "acl": []
  },
  {
    "name": "www_threefold_cloud",
    "url": "https://github.com/threefoldfoundation/www_threefold_cloud",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 2,
    "shortname": "cloud",

    "domains": ["cloud.threefold.io", "cloud.threefold.me"],
    "descr": "for people looking to deploy solutions on top of a cloud, alternative to e.g. digital ocean",
    "groups": [],
    "acl": [
      {
        "groups": ["tf2"],
        "users": ["polleke2"],
        "rights": "R",
        "secrets": ["1234", "5678"]
      }
    ]
  },
  {
    "name": "www_threefold_farming",
    "url": "https://github.com/threefoldfoundation/www_threefold_farming",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 2,
    "shortname": "farming",

    "domains": ["farming.threefold.io", "farming.threefold.me"],
    "descr": "crypto & minining enthusiasts, be the internet, know about farming & tokens.",
    "circles": [],
    "acl": []
  },
  {
    "name": "www_threefold_twin",
    "url": "https://github.com/threefoldfoundation/www_threefold_twin",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 2,
    "shortname": "twin",

    "domains": ["mydigitaltwin.io", "www.mydigitaltwin.io"],
    "descr": "you digital life",
    "circles": [],
    "acl": []
  },
  {
    "name": "www_threefold_marketplace",
    "url": "https://github.com/threefoldfoundation/www_threefold_marketplace",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 2,
    "shortname": "marketplace",

    "domains": [
      "now.threefold.io",
      "marketplace.threefold.io",
      "now.threefold.me",
      "marketplace.threefold.me"
    ],
    "descr": "apps for community builders, runs on top of evdc",
    "circles": [],
    "acl": []
  },
  {
    "name": "www_conscious_internet",
    "url": "https://github.com/threefoldfoundation/www_conscious_internet",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 2,
    "shortname": "aci",

    "domains": [
      "www.consciousinternet.org",
      "eco.threefold.io",
      "community.threefold.io",
      "eco.threefold.me",
      "community.threefold.me"
    ],
    "descr": "community around threefold, partners, friends, ...",
    "circles": [],
    "acl": []
  },
  {
    "name": "www_threefold_tech",
    "url": "https://github.com/threefoldtech/www_threefold_tech",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 2,
    "shortname": "tftech",

    "domains": ["www.threefold.tech", "threefold.tech"],
    "descr": "cyberpandemic, use the tech to build your own solutions with, certification for TFGrid",
    "circles": [],
    "acl": []
  },
  {
    "name": "www_examplesite",
    "url": "https://github.com/threefoldfoundation/www_examplesite",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 2,
    "shortname": "example",

    "domains": ["example.threefold.io"],
    "descr": "",
    "circles": [],
    "acl": []
  },
  {
    "name": "www_uhuru",
    "url": "https://github.com/uhuru-me/www_uhuru",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 2,
    "shortname": "uhuru",

    "domains": ["www.uhuru.me"],
    "descr": "uhuru (freedom) peer2peer cloud.",
    "circles": [],
    "acl": []
  },
  {
    "name": "www_mitaa",
    "url": "https://github.com/mitaa-me/www_mitaa",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 2,
    "shortname": "mitaa",

    "domains": ["www.mitaa.me"],
    "descr": "Mitaa website.",
    "circles": [],
    "acl": []
  },
  {
    "name": "info_threefold",
    "url": "https://github.com/threefoldfoundation/info_threefold",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 0,
    "shortname": "threefold",

    "domains": ["library.threefold.me", "library.threefold.me"],
    "descr": "wiki for foundation, collaborate, what if farmings, tokens",
    "circles": [],
    "acl": []
  },
  {
    "name": "info_uhuru",
    "url": "https://github.com/uhuru-me/info_uhuru",
    "branch": "s",
    "pull": false,
    "reset": false,
    "cat": 0,
    "shortname": "uhuru",

    "domains": ["info.uhuru.me"],
    "descr": "wiki for uhuru Peer2Peer Cloud.",
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
    "name": "info_mitaa",
    "url": "https://github.com/mitaa-me/info_mitaa",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 0,
    "shortname": "mitaa",

    "domains": ["info.mitaa.me", "info.mitaa.org"],
    "descr": "wiki for Mitaa.",
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
      "legal-library.threefold.me",
      "legal-library.threefold.me"
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

    "domains": ["cloud-library.threefold.me", "cloud-library.threefold.me"],
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

    "domains": ["bt-library.threefold.me"],
    "descr": "",
    "circles": [],
    "acl": []
  },
  {
    "name": "data_threefold",
    "url": "https://github.com/threefoldfoundation/data_threefold",
    "branch": "",
    "pull": false,
    "reset": false,
    "cat": 1,
    "shortname": "data",

    "domains": [],
    "descr": "",
    "circles": [],
    "acl": []
  }
]
```
