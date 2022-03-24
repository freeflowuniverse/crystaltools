# Tracking With Unique ID

Publishtools can help you to track activity using unique id and save it in a log file.

## How to use ?

- let's assume that the normal wiki link like `<SERVER_ADDR>/info/<WIKI_NAME>/#/<PAGE_NAME`

for example `http://localhost:9998/info/publishtools/#/publishtools__readme`
- Now we will add `?id=<UNIQUE_ID>` to the normal link `<SERVER_ADDR>/info/<WIKI_NAME>?id=<UNIQUE_ID>/#/<PAGE_NAME`

let use `test` as unique id `http://localhost:9998/info/publishtools?id=test/#/publishtools__readme`
- You can give this link to anyone and track activity at your publishtools server logs
- Done!

## Logs

- The previous part was from client side, from the server side you will find the logs in your base publishtools directory, By default it will be at `$HOME/publisher/logs`
- Inside logs directory, you will find a directory for each wiki using `<WIKI_NAME>`
- Inside every wiki directory, you will find log files for each `<UNIQUE_ID>` for each day, in this format `<UNIQUE_ID>_YYYY_MM_DD.log`

```
logs
└── publishtools
    ├── demo__2022_03_21.log
    └── test__2022_03_21.log
1 directory, 2 files

```

- Inside the log file you will find a record for each activity, in this format 

`DATE&TIME   USER_IP     STATE       PAGE`

```
2022-03-21 19:05:28	 [::1]	 open	 home
2022-03-21 19:05:32	 [::1]	 move	 publishtools__install
2022-03-21 19:05:34	 [::1]	 move	 publishtools__gitpod
2022-03-21 19:05:37	 [::1]	 move	 publishtools__markdown
2022-03-21 19:05:43	 [::1]	 close	 publishtools__markdown
```

### Logs States

| State | Description                                                                 |
| ----- | --------------------------------------------------------------------------- |
| open  | Starting point using link with unique id                                    |
| move  | Move from the current page to another one from any link inside current page |
| close | Close from the current page                                                 |
