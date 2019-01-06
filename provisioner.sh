#!/bin/bash -xe

KUBEVER=1.13.1-00

apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add repo Docker-CE
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Install Docker-CE
apt-get update
DOCKERVER=$(apt-cache madison docker-ce | grep 18.06 | head -1 | awk '{print $3}')
apt-get install -y docker-ce=$DOCKERVER
usermod -aG docker vagrant

# Add repo Kubernetes
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Install Kubernetes
apt-get update
apt-get install -y kubelet=$KUBEVER kubeadm=$KUBEVER kubectl=$KUBEVER

IP=$(ifconfig enp0s8 | grep inet | awk '{print $2}' | cut -d':' -f2)

if [ "$HOSTNAME" == "master-1" ]; then
  # Init kubeadm
  rm -rf /vagrant/kubeadm-init.log
  kubeadm init --pod-network-cidr=10.244.0.0/16 \
    --apiserver-advertise-address=$IP \
    --service-cidr=10.244.0.0/16 | tee /vagrant/kubeadm-init.log

  # Setup flannel
  mkdir -p $HOME/.kube
  cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  curl -O https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
  sed -i 's/"--kube-subnet-mgr"/"--kube-subnet-mgr", "--iface=enp0s8"/g' kube-flannel.yml
  kubectl apply -f kube-flannel.yml
  kubectl get node
  kubectl get po -o wide -n kube-system

  # Setup kubectl
  VH=/home/vagrant
  VU=$(id vagrant -u)
  VG=$(id vagrant -g)
  mkdir -p $VH/.kube
  cp -i /etc/kubernetes/admin.conf $VH/.kube/config
  chown $VU:$VG $VH/.kube
  chown $VU:$VG $VH/.kube/config
else
  # Join to cluster
  eval $(grep "kubeadm join" /vagrant/kubeadm-init.log)
fi
