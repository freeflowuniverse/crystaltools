import process

job := process.execute({cmd:"find /", timeout:1, die:false, stdout:false, stdout_log:false}) or {panic(err)}
print(job)


job2 := process.execute({cmd:"find /tmp/", timeout:1}) or {panic(err)}
print(job2)