Kubernetes on Vagrant
==

Use Kubeadm on Vagrant to create a multi-master environment for Kubernetes cluster.

Usage
--

Use Ubuntu:

```sh
$ k8v master 🏄 vagrant up
... provision ...
$ k8v master 🏄 vagrant ssh master-1

vagrant@master-1:~$ kubectl get svc --all-namespaces
NAMESPACE     NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE
default       kubernetes   ClusterIP   10.32.0.1    <none>        443/TCP         71m
kube-system   kube-dns     ClusterIP   10.32.0.10   <none>        53/UDP,53/TCP   71m

vagrant@master-1:~$ kubectl get nodes -owide
NAME       STATUS   ROLES    AGE     VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master-1   Ready    master   66m     v1.13.1   192.168.50.11   <none>        Ubuntu 18.04.2 LTS   4.15.0-45-generic   docker://18.6.3
master-2   Ready    master   52m     v1.13.1   192.168.50.12   <none>        Ubuntu 18.04.2 LTS   4.15.0-45-generic   docker://18.6.3
master-3   Ready    master   46m     v1.13.1   192.168.50.13   <none>        Ubuntu 18.04.2 LTS   4.15.0-45-generic   docker://18.6.3
worker-1   Ready    <none>   16m37s  v1.13.1   192.168.50.14   <none>        Ubuntu 18.04.2 LTS   4.15.0-45-generic   docker://18.6.3
worker-2   Ready    <none>   11m41s  v1.13.1   192.168.50.15   <none>        Ubuntu 18.04.2 LTS   4.15.0-45-generic   docker://18.6.3
worker-3   Ready    <none>   9m27s   v1.13.1   192.168.50.16   <none>        Ubuntu 18.04.2 LTS   4.15.0-45-generic   docker://18.6.3

vagrant@master-1:~$ kubectl get po -owide -nkube-system
NAME                               READY   STATUS    RESTARTS   AGE   IP              NODE       NOMINATED NODE   READINESS GATES
coredns-86c58d9df4-g2zwk           1/1     Running   0          68m   10.32.0.3       master-1   <none>           <none>
coredns-86c58d9df4-kkjk7           1/1     Running   0          68m   10.32.0.2       master-1   <none>           <none>
etcd-master-1                      1/1     Running   0          67m   192.168.50.11   master-1   <none>           <none>
etcd-master-2                      1/1     Running   0          54m   192.168.50.12   master-2   <none>           <none>
etcd-master-3                      1/1     Running   0          48m   192.168.50.13   master-3   <none>           <none>
kube-apiserver-master-1            1/1     Running   0          67m   192.168.50.11   master-1   <none>           <none>
kube-apiserver-master-2            1/1     Running   0          54m   192.168.50.12   master-2   <none>           <none>
kube-apiserver-master-3            1/1     Running   0          48m   192.168.50.13   master-3   <none>           <none>
kube-controller-manager-master-1   1/1     Running   0          67m   192.168.50.11   master-1   <none>           <none>
kube-controller-manager-master-2   1/1     Running   0          54m   192.168.50.12   master-2   <none>           <none>
kube-controller-manager-master-3   1/1     Running   0          48m   192.168.50.13   master-3   <none>           <none>
kube-proxy-9d78s                   1/1     Running   0          68m   192.168.50.11   master-1   <none>           <none>
kube-proxy-kbknn                   1/1     Running   0          48m   192.168.50.13   master-3   <none>           <none>
kube-proxy-klgxm                   1/1     Running   0          54m   192.168.50.12   master-2   <none>           <none>
kube-proxy-kqvqg                   1/1     Running   0          12m   192.168.50.14   worker-1   <none>           <none>
kube-scheduler-master-1            1/1     Running   0          67m   192.168.50.11   master-1   <none>           <none>
kube-scheduler-master-2            1/1     Running   0          54m   192.168.50.12   master-2   <none>           <none>
kube-scheduler-master-3            1/1     Running   0          48m   192.168.50.13   master-3   <none>           <none>
weave-net-4fxhn                    2/2     Running   0          48m   192.168.50.13   master-3   <none>           <none>
weave-net-th6d7                    2/2     Running   0          12m   192.168.50.14   worker-1   <none>           <none>
weave-net-vf2ht                    2/2     Running   0          62m   192.168.50.11   master-1   <none>           <none>
weave-net-w97cq                    2/2     Running   0          54m   192.168.50.12   master-2   <none>           <none>
```

Use CoreOS(Linux Container):

```sh
$ k8v master 🏄 export OS=coreos
$ k8v master 🏄 vagrant up
...
```

Required
--

- Hosted Server memory 8G+
- Vagrant >= 2.2
- VirtualBox >= 6.0

Author
--

[linyows](https://github.com/linyows)
