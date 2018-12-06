#!/bin/bash

echo net.bridge.bridge-nf-call-iptables = 1 >> /etc/sysctl.conf
sysctl -p

apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add repo Docker-CE
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Install Docker-CE
apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')
usermod -aG docker vagrant

# Add repo Kubernetes
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Install Kubernetes
apt-get update
apt-get install -y kubelet=1.10.3-00 kubeadm=1.10.3-00 kubectl=1.10.3-00

# Install nfs-client
apt-get install -y nfs-common

# Install GlusterFs Client
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get install -yq python-software-properties
add-apt-repository ppa:gluster/glusterfs-3.12
apt-get update && apt-get install -yq glusterfs-client
