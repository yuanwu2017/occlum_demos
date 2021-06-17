rm -rf vault
rm -rf src
rm -rf bin
rm -rf pkg
export GOPATH=$PWD
export PATH=$PWD/bin:$PATH
out_dir=$PWD/bin
git clone https://github.com/hashicorp/vault.git
cd vault
git checkout -b 1.5 v1.5.0
git apply ../0001-Add-the-buildmode-pie-in-the-vault.patch
make bootstrap
cd ../src/github.com/mitchellh/gox
git apply ../../../../0001-Add-the-buildmode-support.patch
occlum-go build -o $out_dir .
cd ../../../../vault
make dev


