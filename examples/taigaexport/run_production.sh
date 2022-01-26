set -e

#build taiga export
rm -f taiga_export_production

if [[ "$OSTYPE" == "darwin"* ]]; then
    # v -v -d static_boehm  -gc boehm -prod publishtools.v
    v -no-parallel -d net_blocking_sockets -d static_boehm  -g -keepc  -gc boehm taiga_export_production.v
    ulimit -n 10000
else
    v -no-parallel -d net_blocking_sockets -d static_boehm  -g -keepc -gc boehm taiga_export_production.v
    # v -g -keepc -gc boehm taiga_export_production.v
fi
   


# v taiga_export_production.v

# lldb taiga_export_production  --one-line r
./taiga_export_production

#build publishtools
# source ~/env.sh
# build

# lldb publishtools develop --one-line r

# publishtools develop
