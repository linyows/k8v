Kubernetes on Vagrant
==

Use Kubeadm on Vagrant to create a multi-master environment for Kubernetes cluster.

Usage
--

```sh
$ vagrant up
... provision ...
$ vagrant ssh master-1

% kubectl get nodes -o wide
NAME       STATUS   ROLES    AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE           KERNEL-VERSION      CONTAINER-RUNTIME
master-1   Ready    master   39m   v1.13.1   172.16.20.11   <none>        Ubuntu 18.04 LTS   4.15.0-23-generic   docker://18.6.1
node-1     Ready    <none>   34m   v1.13.1   172.16.20.12   <none>        Ubuntu 18.04 LTS   4.15.0-23-generic   docker://18.6.1
node-2     Ready    <none>   32m   v1.13.1   172.16.20.13   <none>        Ubuntu 18.04 LTS   4.15.0-23-generic   docker://18.6.1

% kubectl get po -n kube-system -o wide
NAME                               READY   STATUS    RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
coredns-86c58d9df4-kqqfd           1/1     Running   0          39m   10.244.0.2     master-1   <none>           <none>
coredns-86c58d9df4-z9nns           1/1     Running   0          39m   10.244.0.3     master-1   <none>           <none>
etcd-master-1                      1/1     Running   0          38m   172.16.20.11   master-1   <none>           <none>
kube-apiserver-master-1            1/1     Running   0          39m   172.16.20.11   master-1   <none>           <none>
kube-controller-manager-master-1   1/1     Running   0          39m   172.16.20.11   master-1   <none>           <none>
kube-flannel-ds-amd64-6hsw9        1/1     Running   0          39m   172.16.20.11   master-1   <none>           <none>
kube-flannel-ds-amd64-7d2m2        1/1     Running   0          33m   172.16.20.13   node-2     <none>           <none>
kube-flannel-ds-amd64-vn8cv        1/1     Running   0          35m   172.16.20.12   node-1     <none>           <none>
kube-proxy-9nhcm                   1/1     Running   0          39m   172.16.20.11   master-1   <none>           <none>
kube-proxy-ts8l6                   1/1     Running   0          33m   172.16.20.13   node-2     <none>           <none>
kube-proxy-vdtpb                   1/1     Running   0          35m   172.16.20.12   node-1     <none>           <none>
kube-scheduler-master-1            1/1     Running   0          38m   172.16.20.11   master-1   <none>           <none>
```

Required
--

- Hosted Server memory 8G+
- Vagrant >= 2.2
- VirtualBox >= 6.0

Author
--

[linyows](https://github.com/linyows)
