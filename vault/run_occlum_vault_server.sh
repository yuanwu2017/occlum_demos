#!/bin/bash
occlum_glibc=/opt/occlum/glibc/lib/
set -e

# 1. Init Occlum Workspace
rm -rf occlum_instance
mkdir occlum_instance
cd occlum_instance
occlum init
new_json="$(jq '.resource_limits.user_space_size = "16000MB" |
                .resource_limits.kernel_space_heap_size="512MB" |
                .resource_limits.max_num_of_threads = 1024 |
                .process.default_heap_size = "256MB" |
                .process.default_mmap_size = "1024MB"' Occlum.json)" && \
echo "${new_json}" > Occlum.json

# 2. Copy files into Occlum Workspace and Build
cp ../vault/bin/vault image/bin
cp $occlum_glibc/libdl.so.2 image/$occlum_glibc
cp $occlum_glibc/libm.so.6 image/$occlum_glibc
#cp $occlum_dir/etc/redis.conf image/etc
#cp -r $occlum_dir/etc/logrotate.d image/etc/
#cp $occlum_dir/etc/sentinel.conf image/etc
mkdir image/proc
cp /proc/cpuinfo image/proc
#occlum build
occlum build
# 3. Run benchmark
occlum run /bin/vault server -dev
