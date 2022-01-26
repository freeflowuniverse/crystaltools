set -e

#build taiga export
rm -f vscode_run
v -no-parallel -d net_blocking_sockets -d static_boehm  -g -keepc  -gc boehm vscode_run.v
# v vscode_run.v

# lldb vscode_run  --one-line r
./vscode_run

