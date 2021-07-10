#!/usr/bin/bash

pushd /workspace/publishtools/scripts_workspace
bash build_fast.sh
popd

cd /workspace/publishtools/example
publishtools develop