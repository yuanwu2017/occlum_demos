#!/bin/bash
benchmark=redis_benchmark
occlum_dir=/usr/local/occlum/x86_64-linux-musl
set -e

# 1. Init Occlum Workspace
rm -rf occlum_instance
mkdir occlum_instance
cd occlum_instance
occlum init
new_json="$(jq '.resource_limits.user_space_size = "320MB" |
                .process.default_mmap_size = "256MB"' Occlum.json)" && \
echo "${new_json}" > Occlum.json

# 2. Copy files into Occlum Workspace and Build
cp $occlum_dir/bin/redis* image/bin
cp $occlum_dir/lib/libssl* image/lib
cp $occlum_dir/lib/libcrypto* image/lib
mkdir image/proc
cp /proc/cpuinfo image/proc
#occlum build
occlum build
# 3. Run benchmark
occlum run /bin/redis-server --save "" --appendonly no &
