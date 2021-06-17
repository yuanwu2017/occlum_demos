server_pid=`ps -a | grep occlum-run | grep -v grep | sed 's/^\s*//' | sed 's/[[:space:]].*//'`
kill -9 ${server_pid}
taskset -c 32 numactl -l ./run_occlum_server.sh &
sleep 20
server_pid=`ps -a | grep occlum-run | grep -v grep | sed 's/^\s*//' | sed 's/[[:space:]].*//'`
echo 'start client'
taskset -c 0-31 numactl -l ./run_host_client.sh -resp 4096 -req 128 -d 120 -c 1
taskset -c 0-31 numactl -l ./run_host_client.sh -resp 16384 -req 128 -d 120 -c 1
taskset -c 0-31 numactl -l ./run_host_client.sh -resp 4096 -req 128 -d 120 -c 4
taskset -c 0-31 numactl -l ./run_host_client.sh -resp 16384 -req 128 -d 120 -c 4
taskset -c 0-31 numactl -l ./run_host_client.sh -resp 4096 -req 128 -d 120 -c 32
taskset -c 0-31 numactl -l ./run_host_client.sh -resp 16384 -req 128 -d 120 -c 32
taskset -c 0-31 numactl -l ./run_host_client.sh -resp 4096 -req 128 -d 120 -c 64
taskset -c 0-31 numactl -l ./run_host_client.sh -resp 16384 -req 128 -d 120 -c 64
echo 'kill server'
kill -9 ${server_pid}
sleep 10
taskset -c 32 numactl -l ./run_host_server.sh
sleep 10
server_pid=`ps -a | grep server | grep -v grep | sed 's/^\s*//' | sed 's/[[:space:]].*//'`
taskset -c 0-31 numactl -l ./run_host_client.sh -resp 4096 -req 128 -d 120 -c 1
taskset -c 0-31 numactl -l ./run_host_client.sh -resp 16384 -req 128 -d 120 -c 1
taskset -c 0-31 numactl -l ./run_host_client.sh -resp 4096 -req 128 -d 120 -c 4
taskset -c 0-31 numactl -l ./run_host_client.sh -resp 16384 -req 128 -d 120 -c 4
taskset -c 0-31 numactl -l ./run_host_client.sh -resp 4096 -req 128 -d 120 -c 32
taskset -c 0-31 numactl -l ./run_host_client.sh -resp 16384 -req 128 -d 120 -c 32
taskset -c 0-31 numactl -l ./run_host_client.sh -resp 4096 -req 128 -d 120 -c 64
taskset -c 0-31 numactl -l ./run_host_client.sh -resp 16384 -req 128 -d 120 -c 64
kill -9 ${server_pid}
