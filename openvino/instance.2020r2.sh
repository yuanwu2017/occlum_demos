#!/bin/bash
benchmark=benchmark_app
openvino_dir=/opt/intel/openvino/
benchmark_dir=openvino_src/bin/intel64/Release
occlum_glibc=/opt/occlum/glibc/lib/
set -e

# 1. Init Occlum Workspace
rm -rf occlum_instance
mkdir occlum_instance
cd occlum_instance
occlum init
new_json="$(jq '.resource_limits.user_space_size = "17GB" | .resource_limits.kernel_space_stack_size = "8MB" | .resource_limits.max_num_of_threads = 256 |
                .process.default_mmap_size = "16GB"' Occlum.json)" && \
echo "${new_json}" > Occlum.json

# 2. Copy files into Occlum Workspace and Build
cp ../$benchmark_dir/$benchmark image/bin
cp -r $openvino_dir/lib/* image/$occlum_glibc
cp -r ../$benchmark_dir/lib/* image/$occlum_glibc
cp /usr/lib/x86_64-linux-gnu/libpng16.so.16 image/$occlum_glibc
cp -r ../openvino_src/inference-engine/temp/omp/lib/* image/$occlum_glibc
cp /lib/x86_64-linux-gnu/libz.so.1 image/$occlum_glibc
cp $occlum_glibc/libdl.so.2 image/$occlum_glibc
cp $occlum_glibc/librt.so.1 image/$occlum_glibc
cp $occlum_glibc/libm.so.6 image/$occlum_glibc
cp /proc/cpuinfo image/proc
cp -r ../model image/

