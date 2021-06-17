#!/bin/bash
set -e

BLUE='\033[1;34m'
NC='\033[0m'
INSTANCE_DIR="dcap_demo_instance"

occlum_glibc=/opt/occlum/glibc/lib/

rm -rf ${INSTANCE_DIR} && occlum new ${INSTANCE_DIR}
cd ${INSTANCE_DIR}
cp ../bin/dcap_demo image/bin
cp ../libmbed*  image/lib/
cp ../libmbed* image/$occlum_glibc
cp ../hosts image/etc/
cp /lib/x86_64-linux-gnu/libtinfo.so.5 image/$occlum_glibc
cp /lib/x86_64-linux-gnu/librt.so.1 image/$occlum_glibc
cp /lib/x86_64-linux-gnu/libdl.so.2  image/$occlum_glibc
cp /lib/x86_64-linux-gnu/libresolv.so.2 image/$occlum_glibc
cp /lib/x86_64-linux-gnu/libnss*.so.2 image/$occlum_glibc

occlum build

echo -e "${BLUE}occlum run /bin/dcap_demo${NC}"
occlum run /bin/dcap_demo
