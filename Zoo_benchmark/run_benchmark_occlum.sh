#!/bin/bash

# debug flag
#set -x
occlum_glibc=/opt/occlum/glibc//lib/

init_instance() {
    # Init Occlum instance
    rm -rf occlum_instance && mkdir occlum_instance
    cd occlum_instance
    occlum init
    new_json="$(jq '.resource_limits.user_space_size = "16000MB" |
	.resource_limits.kernel_space_heap_size="512MB" |
	.resource_limits.max_num_of_threads = 256 |
	.process.default_heap_size = "128MB" |
	.process.default_mmap_size = "8192MB" |
	.entry_points = [ "/usr/lib/jvm/java-11-openjdk-amd64/bin" ] |
	.env.default = [ "LD_LIBRARY_PATH=/usr/lib/jvm/java-11-openjdk-amd64/lib/server:/usr/lib/jvm/java-11-openjdk-amd64/lib:/usr/lib/jvm/java-11-openjdk-amd64/../lib:/lib:/occlum-x86_64/openvino" ]' Occlum.json)" && \
    echo "${new_json}" > Occlum.json
}

build_benchmark() {
    # Copy JVM and class file into Occlum instance and build
    mkdir -p image/usr/lib/jvm
    cp -r /usr/lib/jvm/java-11-openjdk-amd64 image/usr/lib/jvm
    cp /lib/x86_64-linux-gnu/libz.so.1 image/lib
    cp $occlum_glibc/libdl.so.2 image/$occlum_glibc
    cp ../$JAR image/bin/
    mkdir -p image/occlum-x86_64/openvino
    occlum build
}

run_benchmark() {
    init_instance
    build_benchmark
    echo -e "${BLUE}occlum run AZ benchmark test${NC}"
    occlum run /usr/lib/jvm/java-11-openjdk-amd64/bin/java \
	-XX:+UseG1GC -Xmx536870902 -Xms536870902 -XX:MaxDirectMemorySize=268435458 -XX:MaxMetaspaceSize=268435456 \
	${OPTIONS} -cp bin/benchmark-0.3.0-SNAPSHOT-jar-with-dependencies.jar \
       	${CLASS} -m ${MODEL} --iteration ${ITER} --batchSize ${BS} ${PARM}

}



HYPER=1
if command -v lscpu &> /dev/null
then
    HYPER=`lscpu |grep "Thread(s) per core"|awk '{print $4}'`
fi

CORES=1
if command -v nproc &> /dev/null
then
    CORES=$(($(nproc) / HYPER))
fi


if [[ -z "${KMP_AFFINITY}" ]]; then
  KMP_AFFINITY=granularity=fine,compact
  if [[ $HYPER -eq 2 ]]; then
    KMP_AFFINITY=${KMP_AFFINITY},1,0
  fi
fi
echo "Hardware Core number ${CORES}"

#export OMP_NUM_THREADS=${CPU}
#export OMP_PROC_BIND=spread
#export KMP_AFFINITY=verbose,disabled
#export KMP_AFFINITY=verbose,granularity=fine,compact,1,0
export KMP_AFFINITY=verbose,granularity=fine,compact
#export KMP_AFFINITY=verbose,granularity=fine

usage()
{
    echo "usage:
       1. type, tf, torch, bigdl, bigdlblas or ov, e,g., bigdl
       2. Model path, e.g., *.model, *.xml
       3. Iteration, e.g., 100
       4. Batch Size, e.g., 32
       as parameters in order. More concretely, you can run this command:
       bash run.sh \\
            bigdl \\
            /path/model \\
            100 \\
            32"
    exit 1
}


OPTIONS=""
PARM=""

if [ "$#" -lt 4 ]
then
    usage
else
    TYPE="$1"
    MODEL="$2"
    ITER="$3"
    BS="$4"
fi

case $TYPE in

  "tf" | "TF")
    echo "Analytics-Zoo with TensorFlow"
    CLASS=com.intel.analytics.zoo.benchmark.inference.TFNetPerf
    ;;

  "torch" | "TORCH")
    echo "Analytics-Zoo with PyTorch"
    CLASS=com.intel.analytics.zoo.benchmark.inference.TorchNetPerf
    export OMP_NUM_THREADS=${CORES}
    ;;

  "bigdl" | "BIGDL")
    echo "Analytics-Zoo with BigDL MKLDNN"
    CLASS=com.intel.analytics.zoo.benchmark.inference.BigDLPerf
    OPTIONS='-Dbigdl.engineType=mkldnn -Dbigdl.mklNumThreads='${CORES}
    ;;

  "bigdlblas" | "BIGDLBLAS")
    echo "Analytics-Zoo with BigDL BLAS"
    CLASS=com.intel.analytics.zoo.benchmark.inference.BigDLBLASPerf
    PARM="-c ${CORES}"
    ;;

  "ov" | "OV")
    echo "Analytics-Zoo with OpenVINO"
    CLASS=com.intel.analytics.zoo.benchmark.inference.OpenVINOPerf
    export OMP_NUM_THREADS=${CORES}
    export KMP_BLOCKTIME=20
    ;;

  *)
    echo "Analytics-Zoo with BigDL MKLDNN"
    CLASS=com.intel.analytics.zoo.benchmark.inference.BigDLPerf
    OPTIONS='-Dbigdl.engineType=mkldnn -Dbigdl.mklNumThreads='${CORES}
    ;;
esac


# for maven
JAR=./Zoo_Benchmark/target/benchmark-0.3.0-SNAPSHOT-jar-with-dependencies.jar

#java ${OPTIONS} -cp ${JAR} ${CLASS} -m ${MODEL} --iteration ${ITER} --batchSize ${BS} ${PARM}
run_benchmark
