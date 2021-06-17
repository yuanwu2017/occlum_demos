#!/bin/bash
set -x
ssl_config_file=/bin/ssl_configure/ssl.cfg

/opt/occlum/start_aesm.sh
cd /root/tf_serving
if [ $cores == 8 ] ; then
prefix="taskset -c 0-7"
fi
$prefix  occlum run /bin/tensorflow_model_server \
    --model_name=${model_name} \
    --model_base_path=/model/${model_name} \
    --port=8500 \
    --rest_api_port=8501 \
    --enable_model_warmup=true \
    --flush_filesystem_caches=false \
    --enable_batching=${enable_batching} \
    --rest_api_num_threads=${rest_api_num_threads} \
    --tensorflow_session_parallelism=${session_parallelism} \
    --tensorflow_intra_op_parallelism=${intra_op_parallelism} \
    --tensorflow_inter_op_parallelism=${inter_op_parallelism} \
    --ssl_config_file=${ssl_config_file}
