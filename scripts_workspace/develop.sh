#!/usr/bin/bash

pushd /workspace/publishtools/scripts_workspace
bash build_fast.sh
popd "$@" > /dev/null

cd /workspace/publishtools/example
publishtools develop