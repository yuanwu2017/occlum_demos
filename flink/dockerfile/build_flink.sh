occlum_glibc=/opt/occlum/glibc/lib/
init_instance() {
    # Init Occlum instance
    rm -rf flink && mkdir flink
    cd flink
    occlum init
    new_json="$(jq '.resource_limits.user_space_size = "16000MB" |
                .resource_limits.kernel_space_heap_size="128MB" |
                .resource_limits.max_num_of_threads = 256 |
                .process.default_heap_size = "128MB" |
                .process.default_mmap_size = "8192MB" |
                .entry_points = [ "/usr/lib/jvm/java-11-openjdk-amd64/bin" ] |
                .env.default = [ "LD_LIBRARY_PATH=/usr/lib/jvm/java-11-openjdk-amd64/lib/server:/usr/lib/jvm/java-11-openjdk-amd64/lib:/usr/lib/jvm/java-11-openjdk-amd64/../lib:/lib" ]' Occlum.json)" && \
    echo "${new_json}" > Occlum.json

   }

build_flink() {
    # Copy JVM and class file into Occlum instance and build
    mkdir -p image/usr/lib/jvm
    cp -r /usr/lib/jvm/java-11-openjdk-amd64 image/usr/lib/jvm
    cp /lib/x86_64-linux-gnu/libz.so.1 image/lib
    cp $occlum_glibc/libdl.so.2 image/$occlum_glibc
    cp $occlum_glibc/librt.so.1 image/$occlum_glibc
    cp $occlum_glibc/libm.so.6 image/$occlum_glibc
    cp $occlum_glibc/libnss_files.so.2 image/$occlum_glibc
    cp -rf ../flink-1.10.1/* image/bin/
    cp -rf ../flink-conf.yaml image/bin/conf/
    rm ../flink-conf.yaml
    cp -rf ../hosts image/etc/
    occlum build
}

#Build the flink occlum instance
init_instance
build_flink
#clean the tmp dir
rm -rf ../flink-1.10.1


