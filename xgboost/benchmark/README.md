# Benchmark for XGBoost

### Enter Workspace
```
cd $occlum/demos/xgboost
chmod +x `find ./ -name '*.sh'`
```

### Prepare dataset
>follow dataset.txt

### Prepare occlum instance
```
./instance.sh
```

### Benchmark of XGBoost
>change $dataset of benchmark.sh
```
./benchmark.sh
```

### Convert model of XGBoost(Optional)
```
./convert.sh
```