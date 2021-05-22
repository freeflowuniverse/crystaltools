#!/bin/bash

set -ex
pushd  ~/code/publishtools
sh build.sh
popd
publishtools develop

