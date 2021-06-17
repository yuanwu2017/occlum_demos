#!/bin/bash
set -e

export benchmark=benchmark_app

# 2019R3
export inference_bin=/root/demos/openvino/openvino_src/inference-engine/bin/intel64/Release
# 2020R2
export inference_bin=/root/demos/openvino/openvino_src/bin/intel64/Release

export model_dir=model
export log_name=host

echo "int8 #####################################################################################################################################################################"
taskset -c 32-32 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-47 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-63 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s

taskset -c 32-32 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 32 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-47 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 32 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-63 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 32 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s

echo "fp32 #####################################################################################################################################################################"
taskset -c 32-32 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-47 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-63 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s

taskset -c 32-32 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 32 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-47 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 32 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-63 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 32 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s

export inference_bin="occlum run /bin"
export model_dir=/model

cd occlum_hw
occlum build --sgx-mode HW
export log_name=../hw

echo "int8 #####################################################################################################################################################################"
taskset -c 32-32 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-47 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-63 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s

taskset -c 32-32 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 32 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-47 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 32 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-63 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 32 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s

echo "fp32 #####################################################################################################################################################################"
taskset -c 32-32 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-47 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-63 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s

taskset -c 32-32 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 32 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-47 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 32 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-63 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 32 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s

cd -

cd occlum_sim
occlum build --sgx-mode SIM
export log_name=../sim

echo "int8 #####################################################################################################################################################################"
taskset -c 32-32 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-47 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-63 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s

taskset -c 32-32 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 32 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-47 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 32 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-63 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50_i8.xml -b 32 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s

echo "fp32 #####################################################################################################################################################################"
taskset -c 32-32 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-47 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-63 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 1 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s

taskset -c 32-32 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 32 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-47 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 32 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s
taskset -c 32-63 numactl -l $inference_bin/$benchmark -m $model_dir/resnet-50.xml -b 32 -nireq 1 -nstreams 1 -nthreads 0 -t 60 | tee -a $log_name.log && sleep 5s

cd -
