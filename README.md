# Custom Scheduler

Toy scheduler for use in Kubernetes demos.

Advise for testing with tmux since multi sessions 
will gain more visuals.

## Step 1: Launch kube-proxy to listen at 8001.

Annotate each node using the annotator command:

```
$ kubectl proxy --address=127.0.0.1 --port=8001
Starting to serve on 127.0.0.1:8001
```

Test run the annotator to see the workload.

```
$ go run annotator/main.go
kubectl-1.k8s.local 1.60
kubenode-1.k8s.local 0.10
kubenode-2.k8s.local 0.80
kubenode-3.k8s.local 1.60
```

### Step 2: Create a 'nginx' deployment.

```
kubectl create -f deployments/nginx.yaml
```
```
deployment "nginx" created
```

The nginx pod should be in a pending state:

```
$ kubectl get pods -l app=nginx
NAME                     READY   STATUS    RESTARTS   AGE
nginx-758fdd8bb8-dhg49   0/1     Pending   0          23s
```

### Run the Scheduler

List the nodes and note the price of each node.

```
$ go run annotator/main.go
kubectl-1.k8s.local 0.80
kubenode-1.k8s.local 0.40
kubenode-2.k8s.local 0.40
kubenode-3.k8s.local 1.60
```

Run the best price scheduler:

```
$ ./custom_scheduler
2018/12/23 22:26:13 Starting custom scheduler...
2018/12/23 22:26:16 Successfully assigned nginx-758fdd8bb8-dhg49 to kubenode-1.k8s.local
```

### Custom test lab.

Confirm that 'ngnix' changes the 'pending' to 'running' state.

```
$ kubectl get pods  -l app=nginx
NAME                     READY   STATUS    RESTARTS   AGE
nginx-758fdd8bb8-dhg49   1/1     Running   0          5m49s

Events:
  Type    Reason     Age    From                           Message
  ----    ------     ----   ----                           -------
  Normal  Scheduled  3m28s  hightower-scheduler            Successfully assigned nginx-758fdd8bb8-dhg49 to kubenode-1.k8s.local
  Normal  Pulling    3m28s  kubelet, kubenode-1.k8s.local  pulling image "nginx:1.11.1-alpine"
  Normal  Pulled     3m16s  kubelet, kubenode-1.k8s.local  Successfully pulled image "nginx:1.11.1-alpine"
  Normal  Created    3m16s  kubelet, kubenode-1.k8s.local  Created container
  Normal  Started    3m16s  kubelet, kubenode-1.k8s.local  Started container
```

Edit deployment to increase replicas.

```
$ kubectl edit deployments nginx
deployment.extensions/nginx edited
```

Deployment consult the custom scheduler to find out which nodes to use.

```
ubuntu@kubectl-1:~/custom_scheduler$ ./custom_scheduler
2018/12/23 22:26:13 Starting custom scheduler...
2018/12/23 22:26:16 Successfully assigned nginx-758fdd8bb8-dhg49 to kubenode-1.k8s.local
2018/12/23 22:34:39 Successfully assigned nginx-758fdd8bb8-fgbjs to kubenode-1.k8s.local
2018/12/23 22:34:41 Successfully assigned nginx-758fdd8bb8-ck4w6 to kubenode-2.k8s.local
```
