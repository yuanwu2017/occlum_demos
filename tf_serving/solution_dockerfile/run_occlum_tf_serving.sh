#!/bin/bash
set -e

function usage_help() {
    echo -e "options:"
    echo -e "  -h Display help"
    echo -e "  -a {image_id}"
    echo -e "  -b {host_ports}"
    echo -e "  -c {model_name}"
    echo -e "  -d {cores}"
    echo -e "  -e {attestation_hosts}"
    echo -e "       Format: '{attestation_domain_name}:{ip}'"
}

# Default args
host_ports="8500-8501"
model_name="resnet50-v15-fp32"
cores=
enable_batching=false
rest_api_num_threads=8
session_parallelism=0
parallel_num_threads=32
file_system_poll_wait_seconds=5
attestation_hosts="localhost:127.0.0.1"
http_proxy=""
https_proxy=""
no_proxy=""
image_id=occlum_tf_serving:latest
# Override args
while getopts "h?r:a:b:c:d:e:f:" OPT; do
    case $OPT in
        h|\?)
            usage_help
            exit 1
            ;;
        a)
            echo -e "Option $OPTIND, image_id = $OPTARG"
            image_id=$OPTARG
            ;;
        b)
            echo -e "Option $OPTIND, host_ports = $OPTARG"
            host_ports=$OPTARG
            ;;
        c)
            echo -e "Option $OPTIND, model_name = $OPTARG"
            model_name=$OPTARG
            ;;
        d)
            echo -e "Option $OPTIND, cores = $OPTARG"
            model_name=$OPTARG
            ;;
        e)
            echo -e "Option $OPTIND, attestation_hosts = $OPTARG"
            attestation_hosts=$OPTARG
            ;;
        :)
            echo -e "Option $OPTARG needs argument"
            usage_help
            exit 1
            ;;
        ?)
            echo -e "Unknown option $OPTARG"
            usage_help
            exit 1
            ;;
    esac
done


docker run \
    -it \
    --rm \
    --device=/dev/sgx_enclave:/dev/sgx/enclave \
    --device=/dev/sgx_provision:/dev/sgx/provision \
    --add-host=${attestation_hosts} \
    -p ${host_ports}:8500-8501 \
    -e http_proxy=${http_proxy} \
    -e https_proxy=${https_proxy} \
    -e no_proxy=${no_proxy} \
    -e model_name=${model_name} \
    -e cores=${cores} \
    -e enable_batching=${enable_batching} \
    -e rest_api_num_threads=${rest_api_num_threads} \
    -e session_parallelism=${session_parallelism} \
    -e intra_op_parallelism=${parallel_num_threads} \
    -e inter_op_parallelism=${parallel_num_threads} \
    -e OMP_NUM_THREADS=${parallel_num_threads} \
    -e MKL_NUM_THREADS=${parallel_num_threads} \
    -e file_system_poll_wait_seconds=${file_system_poll_wait_seconds} \
    ${image_id}
