#!/bin/bash

export core_start=32
export core_stop=47

############################################################################### host
unset xgboost
export xgboost_src=/root/demos/xgboost/xgboost_src
export xgboost=$xgboost_src/xgboost
export dataset=dataset
export model=./

taskset -c $core_start-$core_stop numactl -l $xgboost $dataset/xgboost.conf objective="binary:logistic" tree_method=hist grow_policy=lossguide max_depth=0 max_leaves=255 max_bin=255 data="$dataset/higgs.train" eval[test]="$dataset/higgs.test" eval_metric=auc nthread=16 num_round=50 model_out="$model/higgs_host_hist.model" 2>&1 | tee higgs_host_hist_train.log

############################################################################### hw
unset xgboost
export xgboost="occlum run /bin/xgboost"
export dataset=/data
export model=/host

cd occlum_hw
taskset -c $core_start-$core_stop numactl -l $xgboost $dataset/xgboost.conf objective="binary:logistic" tree_method=hist grow_policy=lossguide max_depth=0 max_leaves=255 max_bin=255 data="$dataset/higgs.train" eval[test]="$dataset/higgs.test" eval_metric=auc nthread=16 num_round=50 model_out="$model/higgs_hw_hist.model" 2>&1 | tee higgs_hw_hist_train.log
cd -

############################################################################### sim
unset xgboost
export xgboost="occlum run /bin/xgboost"
export dataset=/data
export model=/host

cd occlum_sim
taskset -c $core_start-$core_stop numactl -l $xgboost $dataset/xgboost.conf objective="binary:logistic" tree_method=hist grow_policy=lossguide max_depth=0 max_leaves=255 max_bin=255 data="$dataset/higgs.train" eval[test]="$dataset/higgs.test" eval_metric=auc nthread=16 num_round=50 model_out="$model/higgs_sim_hist.model" 2>&1 | tee higgs_sim_hist_train.log
cd -
