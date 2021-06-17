## Server

1. Add DNS record
    - For ingress
        ```
        service_host_name=grpc.tf-serving.service.com
        echo "${host_ip} ${service_host_name}" >> /etc/hosts
        ```

    - For attestation
        ```
        kubectl edit configmap -n kube-system coredns

            hosts {
                ${ip} ${attestation_host_name}
                fallthrough
            }

            prometheus :9153
            forward . /etc/resolv.conf {
                ......
        ```

2. Deploy service and configure ingress
    ```
    kubectl apply -f ./deploy.yaml
    kubectl apply -f ./ingress.yaml
    ```

3. Elastic deployment
   ```
    kubectl scale -n occlum-tf-serving deployment.apps/occlum-tf-serving-deployment --replicas 2
    ```

4. Check status
    ```
    kubectl logs -n occlum-tf-serving service/occlum-tf-serving-service
    kubectl get -n occlum-tf-serving ingress
    kubectl describe ingress -n occlum-tf-serving occlum-tf-serving-grpc-ingress
    ```

5. Delete Service and clean ingress configuration (Optional)
    ```
    kubectl delete -f ./deploy.yaml
    ```
