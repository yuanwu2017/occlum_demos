#!/bin/bash
set -e

export core_start=32
export core_stop=63
export benchmark=benchmark_app

# 2019R3
export inference_bin=/root/demos/openvino/openvino_src/inference-engine/bin/intel64/Release
# 2020R2
export inference_bin=/root/demos/openvino/openvino_src/bin/intel64/Release

export model_dir=model
export log_name=host

echo "host int8 #####################################################################################################################################################################"

taskset -c $core_start-$core_stop numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c $core_start-$core_stop numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 3 -nireq 16 -nstreams 16 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s

echo "host fp32 #####################################################################################################################################################################"

taskset -c $core_start-$core_stop numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c $core_start-$core_stop numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 4 -nireq 4 -nstreams 4 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s

export inference_bin="occlum run /bin"
export model_dir=/model

cd occlum_hw
occlum build --sgx-mode HW
export log_name=../hw

echo "hw int8 #####################################################################################################################################################################"

taskset -c $core_start-$core_stop numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c $core_start-$core_stop numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 3 -nireq 16 -nstreams 16 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s

echo "hw fp32 #####################################################################################################################################################################"

taskset -c $core_start-$core_stop numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c $core_start-$core_stop numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 4 -nireq 4 -nstreams 4 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s

cd -

cd occlum_sim
occlum build --sgx-mode SIM
export log_name=../sim

echo "sim int8 ####################################################################################################################################################################"

taskset -c $core_start-$core_stop numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c $core_start-$core_stop numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 3 -nireq 16 -nstreams 16 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s

echo "sim fp32 #####################################################################################################################################################################"

taskset -c $core_start-$core_stop numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c $core_start-$core_stop numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 4 -nireq 4 -nstreams 4 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s

cd -
