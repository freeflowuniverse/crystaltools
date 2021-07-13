#!/bin/bash

set -e

pushd ../scripts_workspace
bash build_fast.sh
popd "$@" > /dev/null

publishtools develop

