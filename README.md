# Install a 3 node (1 control plane,2 worker) cluster 
# 1) Install helm for package management and etcdctl (only on Master)
```console
sudo apt update
sudo apt install etcd-client
sudo snap install helm --classic
```

# 2) install containerd CRI
```console
sudo install_cri.sh
```

# 3) install kubetools
```console
sudo install_kubetools.sh
```

# 4) Run Kubeadm on Master
```console
sudo kubeadm init
```

# 5) Install the network plugin Calico and check for pod status in the kube-system namesapce
```console
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

# 6) Get the token from the Master to run on the worker nodes
```console
sudo kubeadm token create --print-join-command
```

# 7) install metric servers
### info on https://github.com/kubernetes-sigs/metrics-server
```console
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# check the pods on the kube-system namespace
# edit the deploy
kubectl -n kube-system edit deploy/metrics-server
# add the following  in spec.templates.spec.containers.args
--kubelet-insecure-tls
--kubelet-preferred-address-type=InternalIP,ExternalIP,Hostname

# check the logs of the metrics-server pod should say "generating selfsigned cert"

# test the metric output
kubectl top pods --all-namespace
```

# 8) install ingress nginx
```console
helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace 
```
