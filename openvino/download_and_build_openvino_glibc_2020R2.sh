#!/bin/bash
OCCLUM_LINKER=/opt/occlum/glibc/lib/ld-linux-x86-64.so.2
THREADING=OMP
PREFIX=/opt/intel/openvino
set -e
show_usage() {
echo
echo "Usage: $0 [--threading <TBB/OMP>]"
echo
exit 1
}

build_opencv() {
    rm -rf deps/opencv && mkdir -p deps/opencv
    pushd deps/opencv
    git clone https://github.com/opencv/opencv .
    git checkout tags/4.1.0 -b 4.1.0
    mkdir build
    cd build
    cmake ../ \
      -DCMAKE_BUILD_TYPE=RELEASE \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DENABLE_PRECOMPILED_HEADERS=OFF \
      -DOPENCV_PC_FILE_NAME=opencv.pc \
      -DOPENCV_GENERATE_PKGCONFIG=ON \
      -DBUILD_opencv_java=OFF -DBUILD_JAVA_SUPPORT=OFF \
      -DBUILD_opencv_python=OFF -DBUILD_PYTHON_SUPPORT=OFF \
      -DBUILD_EXAMPLES=OFF -DWITH_FFMPEG=OFF \
      -DWITH_QT=OFF -DWITH_CUDA=OFF
    make -j`nproc`
    sudo make install
    popd
}
# Build OpenVINO
build_openvino() {
export OpenCV_DIR=$PREFIX/lib/cmake/opencv4
# upgrade cmake
wget "https://github.com/Kitware/CMake/releases/download/v3.18.4/cmake-3.18.4.tar.gz"
tar -xvzf cmake-3.18.4.tar.gz 
(cd cmake-3.18.4 && ./bootstrap --parallel="$(nproc --all)" && make --jobs="$(nproc --all)" && sudo make install)
rm -rf cmake-3.18.4 cmake-3.18.4.tar.gz
hash -r
# clone and build openvino
rm -rf openvino_src && mkdir openvino_src
pushd openvino_src
git clone https://github.com/openvinotoolkit/openvino.git .
git checkout tags/2020.2 -b 2020.2
git submodule init
git submodule update --recursive
#rm -rf build
mkdir build && cd build
#cd build
# Substitute THREADING lib
cmake ../ \
-DTHREADING=$THREADING \
-DENABLE_MKL_DNN=ON \
-DCMAKE_INSTALL_PREFIX=$PREFIX \
-DENABLE_CLDNN=OFF \
-DENABLE_MYRIAD=OFF \
-DENABLE_GNA=OFF
make -j`nproc`
popd
}
while [ -n "$1" ]; do
case "$1" in
--threading) [ -n "$2" ] && THREADING=$2 ; shift 2 || show_usage ;;
*)
show_usage
esac
done
# Tell CMake to search for packages in Occlum toolchain's directory only
export PKG_CONFIG_LIBDIR=$PREFIX/lib
if [ "$THREADING" == "TBB" ] ; then
echo "Build OpenVINO with TBB threading"
build_opencv
build_openvino
elif [ "$THREADING" == "OMP" ] ; then
echo "Build OpenVINO with OpenMP threading"
build_opencv
build_openvino
else
echo "Error: invalid threading: $THREADING"
show_usage
fi
