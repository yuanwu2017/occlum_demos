#!/bin/bash
set -e

[ -d occlum_instance ] && rm -rf occlum_instance
mkdir occlum_instance && cd occlum_instance

occlum init

jq '.resource_limits.user_space_size = "3GB" | .process.default_mmap_size = "2GB"' Occlum.json > tmp.json && mv tmp.json Occlum.json
cp ../speedtest1 image/bin/

occlum build --sgx-mode HW
