#!/bin/bash
set -e

BLUE='\033[1;34m'
NC='\033[0m'

init_instance() {
    # Init Occlum instance
    postfix=$1
    FLINK_LOG_PREFIX="/host/flink--$postfix-${id}"
    log="${FLINK_LOG_PREFIX}.log"
    out="./flink--$postfix-${id}.out"

    rm -rf occlum_instance_$postfix && mkdir occlum_instance_$postfix
    cd occlum_instance_$postfix
    occlum init
    if [ "$postfix" == "server" ] ; then
    	new_json="$(jq '.resource_limits.user_space_size = "16000MB" |
                .resource_limits.kernel_space_heap_size="512MB" |
                .resource_limits.max_num_of_threads = 256 |
                .process.default_heap_size = "128MB" |
                .process.default_mmap_size = "4096MB" |
                .entry_points = [ "/usr/lib/jvm/java-11-alibaba-dragonwell/jre/bin" ] |
                .env.default = [ "LD_LIBRARY_PATH=/usr/lib/jvm/java-11-alibaba-dragonwell/jre/lib/server:/usr/lib/jvm/java-11-alibaba-dragonwell/jre/lib:/usr/lib/jvm/java-11-alibaba-dragonwell/jre/../lib" ]' Occlum.json)" && \
    	echo "${new_json}" > Occlum.json
    else
	new_json="$(jq '.resource_limits.user_space_size = "16000MB" |
                .resource_limits.kernel_space_heap_size="512MB" |
                .resource_limits.max_num_of_threads = 256 |
                .process.default_heap_size = "128MB" |
                .process.default_mmap_size = "4096MB" |
                .entry_points = [ "/usr/lib/jvm/java-11-alibaba-dragonwell/jre/bin" ] |
                .env.default = [ "LD_LIBRARY_PATH=/usr/lib/jvm/java-11-alibaba-dragonwell/jre/lib/server:/usr/lib/jvm/java-11-alibaba-dragonwell/jre/lib:/usr/lib/jvm/java-11-alibaba-dragonwell/jre/../lib" ]' Occlum.json)" && \
    	echo "${new_json}" > Occlum.json

    fi
}

build_flink() {
    # Copy JVM and class file into Occlum instance and build
    mkdir -p image/usr/lib/jvm
    cp -r /opt/occlum/toolchains/jvm/java-11-alibaba-dragonwell image/usr/lib/jvm
    cp /usr/local/occlum/x86_64-linux-musl/lib/libz.so.1 image/lib
    cp -rf ../flink-1.10.1/* image/bin/
    cp -rf ../hosts image/etc/
    occlum build
}

run_server() {
    init_instance server
    build_flink
    echo -e "${BLUE}occlum run JVM flink_server${NC}"
    echo -e "${BLUE}logfile=$log${NC}"
    occlum run /usr/lib/jvm/java-11-alibaba-dragonwell/jre/bin/java -Xms1024m -Xmx1024m \
	-Dlog.file=$log \
	-Dlog4j.configuration=file:/bin/conf/log4j.properties \
	-Dlogback.configurationFile=file:/bin/conf/logback.xml \
	-classpath /bin/lib/flink-table-blink_2.11-1.10.1.jar:/bin/lib/flink-table_2.11-1.10.1.jar:/bin/lib/log4j-1.2.17.jar:/bin/lib/slf4j-log4j12-1.7.15.jar:/bin/lib/flink-dist_2.11-1.10.1.jar org.apache.flink.runtime.entrypoint.StandaloneSessionClusterEntrypoint \
	--configDir /bin/conf \
	--executionMode cluster &
	#-Dorg.apache.flink.shaded.netty4.io.netty.tryReflectionSetAccessible=true \
        #-Dorg.apache.flink.shaded.netty4.io.netty.eventLoopThreads=24 \
}


run_taskmanager() {
    init_instance taskmanager
    build_flink
    echo -e "${BLUE}occlum run JVM taskmanager${NC}"
    echo -e "${BLUE}logfile=$log${NC}"
    occlum run /usr/lib/jvm/java-11-alibaba-dragonwell/jre/bin/java \
	-XX:+UseG1GC -Xmx536870902 -Xms536870902 -XX:MaxDirectMemorySize=268435458 -XX:MaxMetaspaceSize=268435456 \
	-Dlog.file=$log \
	-Dlog4j.configuration=file:/bin/conf/log4j.properties \
	-Dlogback.configurationFile=file:/bin/conf/logback.xml \
	-classpath /bin/lib/flink-table-blink_2.11-1.10.1.jar:/bin/lib/flink-table_2.11-1.10.1.jar:/bin/lib/log4j-1.2.17.jar:/bin/lib/slf4j-log4j12-1.7.15.jar:/bin/lib/flink-dist_2.11-1.10.1.jar org.apache.flink.runtime.taskexecutor.TaskManagerRunner \
	--configDir /bin/conf \
	-D taskmanager.memory.framework.off-heap.size=134217728b \
	-D taskmanager.memory.network.max=134217730b \
	-D taskmanager.memory.network.min=134217730b \
	-D taskmanager.memory.framework.heap.size=134217728b \
	-D taskmanager.memory.managed.size=536870920b \
	-D taskmanager.cpu.cores=1.0 \
	-D taskmanager.memory.task.heap.size=402653174b \
	-D taskmanager.memory.task.off-heap.size=0b &

}

run_task() {
    export FLINK_CONF_DIR=/home/yuanwu/occlum/demos/flink/flink-1.10.1/conf && \
        ./flink-1.10.1/bin/flink run ./flink-1.10.1/examples/streaming/WordCount.jar
    #export FLINK_CONF_DIR=./flink-1.10.1/conf && \
    #     ./flink-1.10.1/bin/flink run ./flink-1.10.1/examples/streaming/IncrementalLearning.jar  --input $2  --output $3

    #export FLINK_CONF_DIR=./flink-1.10.1/conf && \
    #	./flink-1.10.1/bin/flink run ./flink-1.10.1/examples/streaming/Twitter.jar  --input $2  --output $3
    #export FLINK_CONF_DIR=./flink-1.10.1/conf && \
    #	./flink-1.10.1/bin/flink run ./flink-1.10.1/examples/streaming/Iteration.jar  --input $2  --output $3

    #export FLINK_CONF_DIR=./flink-1.10.1/conf && \
    #    ./flink-1.10.1/bin/flink run ./flink-1.10.1/examples/streaming/SessionWindowing.jar  --input $2  --output $3
}

id=$([ -f "$pid" ] && echo $(wc -l < "$pid") || echo "0")

arg=$1
case "$arg" in
    server)
        run_server
	cd ../
        ;;
    tm)
        run_taskmanager
	cd ../
        ;;
    task)
        run_task
	cd ../
        ;;
esac
