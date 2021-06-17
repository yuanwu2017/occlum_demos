#!/bin/bash

export xgboost_src=/root/demos/xgboost/xgboost_src
export xgboost=$xgboost_src/xgboost
export dataset=.

echo "eta = 0.1
max_depth = 8
min_child_weight=100
nthread=16
gamma=0
lambda=0
alpha=0
verbosity=2
seed=1000
num_round=100" > $dataset/xgboost.conf

mkdir occlum_instance
cd occlum_instance
occlum init

jq '.resource_limits.user_space_size = "10GB" | .resource_limits.kernel_space_heap_size = "256MB" | .resource_limits.kernel_space_stack_size = "8MB" | .resource_limits.max_num_of_threads = 256' Occlum.json > tmp.json && mv tmp.json Occlum.json
jq '.process.default_heap_size = "512MB" | .process.default_mmap_size = "9GB"' Occlum.json > tmp.json && mv tmp.json Occlum.json

cp $xgboost image/bin
cp $xgboost_src/lib/libxgboost.so image/lib

mkdir image/data
cp $dataset/xgboost.conf image/data
cp $dataset/higgs.train image/data
cp $dataset/higgs.test image/data
cd -

echo 'occlum_hw occlum_sim' | xargs -n 1 cp -r occlum_instance
cd occlum_hw && occlum build --sgx-mode HW && cd -
cd occlum_sim && occlum build --sgx-mode SIM && cd -
