apt-get update
apt-get install openjdk-11-jdk
#!/bin/bash
set -e

BLUE='\033[1;34m'
NC='\033[0m'
occlum_glibc=/opt/occlum/glibc//lib/

init_instance() {
    # Init Occlum instance
    javac HelloJNI.java -h .
    gcc -o libHelloImpl.so -lc -shared -I/usr/lib/jvm/java-11-openjdk-amd64/include -I/usr/lib/jvm/java-11-openjdk-amd64/include/linux HelloJNI.c
    jar cvf HelloJNI.jar HelloJNI.class libHelloImpl.so HelloJNI.h
    rm -rf occlum_instance && mkdir occlum_instance
    cd occlum_instance
    occlum init
    new_json="$(jq '.resource_limits.user_space_size = "16000MB" |
	.resource_limits.kernel_space_heap_size="512MB" |
	.resource_limits.max_num_of_threads = 256 |
	.process.default_heap_size = "128MB" |
	.process.default_mmap_size = "8192MB" |
	.entry_points = [ "/usr/lib/jvm/java-11-openjdk-amd64/bin" ] |
	.env.default = [ "LD_LIBRARY_PATH=/usr/lib/jvm/java-11-openjdk-amd64/lib/server:/usr/lib/jvm/java-11-openjdk-amd64/lib:/usr/lib/jvm/java-11-openjdk-amd64/../lib:/lib" ]' Occlum.json)" && \
    echo "${new_json}" > Occlum.json
}

build_hello() {
    # Copy JVM and class file into Occlum instance and build
    mkdir -p image/usr/lib/jvm
    cp -r /usr/lib/jvm/java-11-openjdk-amd64 image/usr/lib/jvm
    cp /lib/x86_64-linux-gnu/libz.so.1 image/lib
    cp $occlum_glibc/libdl.so.2 image/$occlum_glibc
    cp ../HelloJNI.jar image/bin/
    cp ../libHelloImpl.so image/lib/
    occlum build
}

run_hello() {
    init_instance
    build_hello
    echo -e "${BLUE}occlum run JVM java_jni test${NC}"
    echo -e "${BLUE}logfile=$log${NC}"
    occlum run /usr/lib/jvm/java-11-openjdk-amd64/bin/java \
	-XX:+UseG1GC -Xmx536870902 -Xms536870902 -XX:MaxDirectMemorySize=268435458 -XX:MaxMetaspaceSize=268435456 \
	-classpath /bin/HelloJNI.jar \
	HelloJNI HelloWorld 2

}

run_hello
