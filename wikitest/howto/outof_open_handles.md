
# Out of open handles issue

if you get:

```bash
error: cannot create standard output pipe for ssh: Too many open files
```
 

do the following in your terminal

```bash
ulimit -n 10000
```