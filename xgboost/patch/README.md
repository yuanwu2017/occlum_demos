# XGBoost version patch for occlum 

### Upgrade Cmake and Apply patch
```
chmod +x `find ./ -name '*.sh'`
cp -r * $occlum/demos/xgboost
```

### Build XGBoost
```
cd $occlum/demos/xgboost
./download_and_build_xgboost.sh
```
