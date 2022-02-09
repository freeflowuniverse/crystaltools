# taigaprojectexport

Taiga full project export example

## Building and sage

Building:

```
$ v export_project.v
```

Example:

```
$ ./export_project --username myuser --password password --id 100 --slug myuser-project_alpha
```

Full options:

```
$ ./export_project -h

export_project v0.1
-----------------------------------------------
Usage: export_project [options]

Description: A tool to test full taiga project export api

This application does not expect any arguments

Options:
  -l, --url <string>        taiga instance URL. defaults to https://circles.threefold.me
  -u, --username <string>   taiga user name
  -p, --password <string>   taiga password
  --id <int>                project id
  -s, --slug <string>       project slug
  -h, --help                display this help and exit
  --version                 output version information and exit

```
