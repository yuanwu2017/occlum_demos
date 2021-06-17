workdir=/root/flink-1.10.1
conf_dir=/root/conf
if [ -d $conf_dir  ];then
    cp -r $conf_dir/* $workdir/conf/
    rm -rf $conf_dir
fi

echo "$workdir"
java  -Xms1024m -Xmx1024m  -Dlog.file=$workdir/log/flink--standalonesession-0-4bf84744d45d.log -Dlog4j.configuration=file:$workdir/conf/log4j.properties -Dlogback.configurationFile=file:$workdir/conf/logback.xml -classpath $workdir/lib/flink-table-blink_2.11-1.10.1.jar:$workdir/lib/flink-table_2.11-1.10.1.jar:$workdir/lib/log4j-1.2.17.jar:$workdir/lib/slf4j-log4j12-1.7.15.jar:$workdir/lib/flink-dist_2.11-1.10.1.jar::: org.apache.flink.runtime.entrypoint.StandaloneSessionClusterEntrypoint --configDir $workdir/conf --executionMode cluster &
echo -e "${BLUE}Flink webservice${NC}"
