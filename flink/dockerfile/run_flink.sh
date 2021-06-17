#!/bin/bash
set -e

BLUE='\033[1;34m'
NC='\033[0m'
conf_dir=/root/conf

id=$([ -f "$pid" ] && echo $(wc -l < "$pid") || echo "0")
FLINK_LOG_PREFIX="/host/flink--$postfix-${id}"
log="${FLINK_LOG_PREFIX}.log"

run_taskmanager() {
    pushd /root/flink
    #if conf_dir exists, use the new configurations.
    if [ -d $conf_dir  ];then
        cp -r $conf_dir/* image/bin/conf/
	occlum build
	rm -rf $confi_dir
    fi


    cp -r $conf_dir/* image/bin/conf/
    echo -e "${BLUE}occlum run JVM taskmanager${NC}"
    echo -e "${BLUE}logfile=$log${NC}"
    occlum run /usr/lib/jvm/java-11-openjdk-amd64/bin/java \
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
    popd

}


run_taskmanager
