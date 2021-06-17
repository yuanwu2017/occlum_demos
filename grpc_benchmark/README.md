1. Download and build the grpc benchmark
$./download_and_build_grpc_benchmark.sh

2. Run the all local benchmarks
$./benchmark.sh

3. Run the host benchmark
$./run_host_bench.sh

4. Run the occlum benchmark
$./run_occlum_bench.sh

5. Run the server and client in different machine.
Step1: Run the server application fistly
$./run_host_server.sh
or
$./run_occlum_server.sh
Note: If you are running occlum server, please wait for several minutes.
Step2: Modify the ip address to server ip in the run_host_client.sh, and run the client app in another machine.
$./run_host_client.sh

Note: If you run the server application in a docker, you need to publish the container's port to host.
For example:
$./docker run -p 5001:5001 -it  --device /dev/sgx  IMAGE_ID

