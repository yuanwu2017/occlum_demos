apt-get update
apt-get install openjdk-11-jdk
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/
workdir=$PWD
echo "$workdir"
java  -Xms1024m -Xmx1024m  -Dlog.file=$workdir/flink-1.10.1/log/flink--standalonesession-0-4bf84744d45d.log -Dlog4j.configuration=file:$workdir/flink-1.10.1/conf/log4j.properties -Dlogback.configurationFile=file:$workdir/flink-1.10.1/conf/logback.xml -classpath $workdir/flink-1.10.1/lib/flink-table-blink_2.11-1.10.1.jar:$workdir/flink-1.10.1/lib/flink-table_2.11-1.10.1.jar:$workdir/flink-1.10.1/lib/log4j-1.2.17.jar:$workdir/flink-1.10.1/lib/slf4j-log4j12-1.7.15.jar:$workdir/flink-1.10.1/lib/flink-dist_2.11-1.10.1.jar::: org.apache.flink.runtime.entrypoint.StandaloneSessionClusterEntrypoint --configDir $workdir/flink-1.10.1/conf --executionMode cluster &
echo -e "${BLUE}Flink webservice${NC}"
