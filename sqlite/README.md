# SQLite

### Apply patch
```
chmod +x `find ./ -name '*.sh'`
cp -r *.sh $occlum/demos/sqlite
cd $occlum/demos/sqlite
```

### Build sqlite
```
./download_and_build_sqlite.sh
```

### Prepare occlum instance
```
./instance.sh
```

### Run speedtest
```
./benchmark.sh
```
