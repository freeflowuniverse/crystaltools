set -e
cd publishtools
# v run publishtools.v develop
v -gc boehm run publishtools.v develop
# v -gc boehm run publishtools.v publish
# v -gc boehm -prod publishtools.v