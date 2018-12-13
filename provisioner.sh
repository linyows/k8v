#!/bin/bash -xe

KUBEVER=1.10.3-00

apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add repo Docker-CE
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Install Docker-CE
apt-get update
DOCKERVER=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')
apt-get install -y docker-ce=$DOCKERVER
usermod -aG docker vagrant

# Add repo Kubernetes
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Install Kubernetes
apt-get update
apt-get install -y kubelet=$KUBEVER kubeadm=$KUBEVER kubectl=$KUBEVER

# Install nfs-client
apt-get install -y nfs-common

# Install GlusterFs Client
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get install -yq python-software-properties
add-apt-repository ppa:gluster/glusterfs-3.12
apt-get update && apt-get install -yq glusterfs-client

IP=$(ifconfig enp0s8 | grep inet | awk '{print $2}' | cut -d':' -f2)
cat <<EOF >/etc/systemd/system/kubelet.service.d/10-kubeadm.conf
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_SYSTEM_PODS_ARGS=--pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true"
Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"
Environment="KUBELET_DNS_ARGS=--cluster-dns=10.244.0.10 --cluster-domain=cluster.local --node-ip=$IP"
Environment="KUBELET_AUTHZ_ARGS=--authorization-mode=Webhook --client-ca-file=/etc/kubernetes/pki/ca.crt"
Environment="KUBELET_CADVISOR_ARGS=--cadvisor-port=0"
Environment="KUBELET_CERTIFICATE_ARGS=--rotate-certificates=true --cert-dir=/var/lib/kubelet/pki"
ExecStart=
ExecStart=/usr/bin/kubelet \$KUBELET_KUBECONFIG_ARGS \$KUBELET_SYSTEM_PODS_ARGS \$KUBELET_NETWORK_ARGS \$KUBELET_DNS_ARGS \$KUBELET_AUTHZ_ARGS \$KUBELET_CADVISOR_ARGS \$KUBELET_CERTIFICATE_ARGS \$KUBELET_EXTRA_ARGS
EOF
systemctl daemon-reload
systemctl restart kubelet

# Init kubeadm
if [ "$HOSTNAME" == "node-1" ]; then
  kubeadm init --pod-network-cidr=10.244.0.0/16 \
    --apiserver-advertise-address=$IP \
    --service-cidr=10.244.0.0/16 | tee /kube-config
fi

# Setup flannel
if [ "$HOSTNAME" == "node-1" ]; then
  mkdir -p $HOME/.kube
  cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  curl -O https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
  sed -i 's/"--kube-subnet-mgr"/"--kube-subnet-mgr", "--iface=enp0s8"/g' kube-flannel.yml
  kubectl apply -f kube-flannel.yml
  kubectl get node
  kubectl get po -o wide -n kube-system
fi

VH=/home/vagrant
VU=$(id vagrant -u)
VG=$(id vagrant -g)
mkdir -p $VH/.kube
cp -i /etc/kubernetes/admin.conf $VH/.kube/config
chown $VU:$VG $VH/.kube
chown $VU:$VG $VH/.kube/config

