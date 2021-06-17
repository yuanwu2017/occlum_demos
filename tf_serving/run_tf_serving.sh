#!/bin/bash
set -e
ssl_config_file=./ssl_configure/ssl.cfg
model_name=$PWD/resnet50-v15-fp32
enable_batching=false
rest_api_num_threads=64
session_parallelism=0
parallel_num_threads=32



# 3. Run benchmark
tensorflow_model_server \
    --model_name=${model_name} \
    --model_base_path=${model_name} \
    --port=8500 \
    --rest_api_port=8501 \
    --enable_model_warmup=true \
    --flush_filesystem_caches=false \
    --enable_batching=${enable_batching} \
    --rest_api_num_threads=${rest_api_num_threads} \
    --tensorflow_session_parallelism=${session_parallelism} \
    --tensorflow_intra_op_parallelism=${parallel_num_threads} \
    --tensorflow_inter_op_parallelism=${parallel_num_threads} \
    --ssl_config_file=${ssl_config_file} \
