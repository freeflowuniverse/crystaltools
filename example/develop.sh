#!/bin/bash

set -ex

pushd ../scripts_workspace
bash build_fast.sh
popd

publishtools develop

