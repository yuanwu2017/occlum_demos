#!/bin/bash
set -e

export core_start=32
export core_stop=32
export log=benchmark.log

export speedtest=./speedtest1
taskset -c $core_start-$core_stop numactl -l $speedtest --testset main --memdb --stats --size 1000 | tee -a $log

cd occlum_instance

SGX_MODE=HW occlum build
export speedtest="occlum run /bin/speedtest1"
taskset -c $core_start-$core_stop numactl -l $speedtest --testset main --memdb --stats --size 1000 | tee -a ../$log

SGX_MODE=SIM occlum build
export speedtest="occlum run /bin/speedtest1"
taskset -c $core_start-$core_stop numactl -l $speedtest --testset main --memdb --stats --size 1000 | tee -a ../$log
