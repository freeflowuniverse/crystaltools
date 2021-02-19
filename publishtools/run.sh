#!/bin/bash
# set -ex
cp publishermod/index_root.html .
# cp publishermod/index_root_prefix.html .
cp publishermod/errors.html .

# sudo v run publishtools.v run
v run publishtools.v develop

#rm -f index_root.html
#rm -f errors.html