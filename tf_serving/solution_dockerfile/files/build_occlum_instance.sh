#!/bin/bash
occlum_glibc=/opt/occlum/glibc/lib/
host_libs=/lib/x86_64-linux-gnu/
set -e


unset http_proxy https_proxy


# 1. Init Occlum Workspace
rm -rf tf_serving
mkdir tf_serving
cd tf_serving
occlum init
cores=$1
if [ "$cores" == "8" ] ; then
	new_json="$(jq '.resource_limits.user_space_size = "8000MB" |
					.resource_limits.kernel_space_heap_size="512MB" |
					.process.default_heap_size = "128MB" |
					.resource_limits.max_num_of_threads = 128 |
					.process.default_mmap_size = "7000MB" |
					.env.default = [ "OMP_NUM_THREADS=8", "KMP_AFFINITY=verbose,granularity=fine,compact,1,0", "KMP_BLOCKTIME=20", "MKL_NUM_THREADS=8"]' Occlum.json)" && \
	echo "${new_json}" > Occlum.json
else
	new_json="$(jq '.resource_limits.user_space_size = "48000MB" |
					.resource_limits.kernel_space_heap_size="512MB" |
					.process.default_heap_size = "128MB" |
					.resource_limits.max_num_of_threads = 1024 |
					.process.default_mmap_size = "46000MB" |
					.env.default = [ "OMP_NUM_THREADS=32", "KMP_AFFINITY=verbose,granularity=fine,compact,1,0", "KMP_BLOCKTIME=20", "MKL_NUM_THREADS=32"]' Occlum.json)" && \
	echo "${new_json}" > Occlum.json
fi

# 2. Copy files into Occlum Workspace and Build
mkdir -p image/model
cp -rf ../resnet50-v15-fp32  image/model/
cp -rf ../ssl_configure  image/bin/
cp ../tensorflow_model_server image/bin
cp ../hosts image/etc/
cp $occlum_glibc/libdl.so.2 image/$occlum_glibc
cp $occlum_glibc/librt.so.1 image/$occlum_glibc
cp $occlum_glibc/libm.so.6 image/$occlum_glibc
cp $occlum_glibc/libutil.so.1 image/$occlum_glibc
cp $occlum_glibc/libpthread.so.0 image/$occlum_glibc
cp $occlum_glibc/libnss_files.so.2 image/$occlum_glibc
cp $occlum_glibc/libnss_compat.so.2 image/$occlum_glibc
#cp $occlum_glibc/libnss_nis.so.2 image/$occlum_glibc
#cp $occlum_glibc/libnss_myhostname.so.2 image/$occlum_glibc
#cp $occlum_glibc/libnss_mdns4_minimal.so.2 image/$occlum_glibc
#cp $occlum_glibc/libnss_dns.so.2 image/$occlum_glibc
#cp $occlum_glibc/libresolv.so.2 image/$occlum_glibc

#occlum build
occlum build
