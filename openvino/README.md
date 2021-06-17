# OpenVINO

### Apply patch
```
chmod +x `find ./ -name '*.sh'`
cp -r *.sh $occlum/demos/openvino
cd $occlum/demos/openvino
```

### Build openvino
```
./download_and_build_openvino.sh
```

### Prepare occlum instance
```
./instance.sh
```
>cp -r $dataset/resnet* occlum_instance/image/model
```
cp -r occlum_instance occlum_hw
mv occlum_instance occlum_sim
cd occlum_hw && occlum build --sgx-mode HW && cd -
cd occlum_sim && occlum build --sgx-mode SIM && cd -
```

### Run benchmark
```
./benchmark.sh
```
