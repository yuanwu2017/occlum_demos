#!/bin/bash

unset xgboost
export xgboost_src=/root/demos/xgboost/xgboost_src
export xgboost=$xgboost_src/xgboost
export dataset=dataset

$xgboost $dataset/xgboost.conf objective="binary:logistic" model_in="./higgs_host_hist.model" task=dump dump_format=json name_dump="higgs_host_hist.json"

$xgboost $dataset/xgboost.conf objective="binary:logistic" model_in="./higgs_hw_hist.model" task=dump dump_format=json name_dump="higgs_hw_hist.json"

$xgboost $dataset/xgboost.conf objective="binary:logistic" model_in="./higgs_sim_hist.model" task=dump dump_format=json name_dump="higgs_sim_hist.json"
