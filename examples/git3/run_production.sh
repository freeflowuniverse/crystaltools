set -e

#build taiga export
rm -f git3

if [[ "$OSTYPE" == "darwin"* ]]; then
    # v -v -d static_boehm  -gc boehm -prod publishtools.v
    v -no-parallel -d net_blocking_sockets -d static_boehm  -g -keepc  -gc boehm git3.v
    ulimit -n 10000
else
    v -no-parallel -d net_blocking_sockets -d static_boehm  -g -keepc -gc boehm git3.v
    # v -g -keepc -gc boehm taiga_export_production.v
fi
   


# v git3.v

# lldb git3  --one-line r
./git3

