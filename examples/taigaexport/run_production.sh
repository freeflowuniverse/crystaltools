set -ex
rm -f taiga_export_production
v -no-parallel -d net_blocking_sockets -d static_boehm  -g -keepc  -gc boehm taiga_export_production.v
# v taiga_export_production.v
lldb taiga_export_production  --one-line r
# publishtools develop