#!/bin/bash

# https://kubernetes.io/docs/setup/independent/install-kubeadm/

export DIR=/home/core/share
export PATH="$PATH:/opt/bin"
#LBIP=192.168.50.10
LBDNS="k8s.local"
CLUSTERIP="10.32.0.10"
echo "127.0.0.1 $HOSTNAME $LBDNS" >> /etc/hosts
swapoff -a

# Install CNI plugins
CNI_VERSION="v0.6.0"
mkdir -p /opt/cni/bin
curl -sL "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-amd64-${CNI_VERSION}.tgz" | tar -C /opt/cni/bin -xz

# Install crictl
CRICTL_VERSION="v1.11.1"
mkdir -p /opt/bin
curl -sL "https://github.com/kubernetes-incubator/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | tar -C /opt/bin -xz

# Install kubeadm, kubelet, kubectl and add a kubelet systemd service:
RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"

mkdir -p /opt/bin
cd /opt/bin
curl -sL --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
chmod +x {kubeadm,kubelet,kubectl}

curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/kubelet.service" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service
mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/10-kubeadm.conf" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# Specify cgroup driver
echo "DOCKER_CGROUPS=\"--exec-opt native.cgroupdriver=systemd\"" >> /run/metadata/torcx
systemctl enable docker && systemctl restart docker

# Enable kublet
IP=$(ifconfig eth1 | grep 'inet ' | awk '{print $2}')
echo "KUBELET_EXTRA_ARGS=\"--node-ip=$IP --cluster-dns=$CLUSTERIP\"" > /etc/default/kubelet
systemctl enable kubelet && systemctl start kubelet

# Init kubeadm
kubeadm init --config=$DIR/weave/kubeadm-config.yaml --ignore-preflight-errors=NumCPU | tee $DIR/shared/kubeadm-init.log
# Setup kubectl
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
mkdir -p /home/core/.kube
cp -i /etc/kubernetes/admin.conf /home/core/.kube/config
chown -R core:core /home/core/.kube
# Setup CNI
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
