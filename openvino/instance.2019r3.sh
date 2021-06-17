#!/bin/bash
export benchmark=benchmark_app
export inference_bin=/root/demos/openvino/openvino_src/inference-engine/bin/intel64/Release
export occlum_lib=/usr/local/occlum/x86_64-linux-musl/lib
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
cp $inference_bin/$benchmark image/bin
cp $inference_bin/lib/libinference_engine.so image/lib
cp $inference_bin/lib/libformat_reader.so image/lib
cp $inference_bin/lib/libcpu_extension.so image/lib
cp $inference_bin/lib/libHeteroPlugin.so image/lib
cp $inference_bin/lib/libMKLDNNPlugin.so image/lib
cp $inference_bin/lib/plugins.xml image/lib
cp $occlum_lib/libopencv_imgcodecs.so.4.1 image/lib
cp $occlum_lib/libopencv_imgproc.so.4.1 image/lib
cp $occlum_lib/libopencv_core.so.4.1 image/lib
cp $occlum_lib/libopencv_videoio.so.4.1 image/lib
cp $occlum_lib/libz.so.1 image/lib
[ -e $occlum_lib/libtbb.so ] && cp $occlum_lib/libtbb.so image/lib
[ -e $occlum_lib/libtbbmalloc.so ] && cp $occlum_lib/libtbbmalloc.so image/lib
[ -e $occlum_lib/libgomp.so ] && cp $occlum_lib/libgomp.so.* image/lib
mkdir image/proc
cp /proc/cpuinfo image/proc
cp -r ../model image/
