apt-get update
apt-get install numactl
server_pid=`ps -a | grep occlum-run | grep -v grep | sed 's/^\s*//' | sed 's/[[:space:]].*//'`
kill -9 ${server_pid}
#run the occlum benchmark
taskset -c 31 numactl -l ./run_occlum_redis_glibc.sh &
sleep 20
server_pid=`ps -a | grep occlum-run | grep -v grep | sed 's/^\s*//' | sed 's/[[:space:]].*//'`
echo 'start client'
taskset -c 0-30 numactl -l /usr/local/redis/bin/redis-benchmark -n 1000
echo 'kill server'
kill -9 ${server_pid}
sleep 10
#run the host benchmark
taskset -c 31 numactl -l /usr/local/redis/bin/redis-server &
sleep 10
server_pid=`ps -a | grep server | grep -v grep | sed 's/^\s*//' | sed 's/[[:space:]].*//'`
taskset -c 0-30 numactl -l /usr/local/redis/bin/redis-benchmark -n 1000
kill -9 ${server_pid}
