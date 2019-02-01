#!/bin/bash -xe

KUBEVER=1.13.1-00
LBIP=172.16.20.10
LBDNS="k8s.local"
CLUSTERIP="10.244.0.10"

setup_kubectl() {
  mkdir -p $HOME/.kube
  cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  mkdir -p /home/vagrant/.kube
  cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
  chown -R vagrant:vagrant /home/vagrant/.kube
}

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
apt-mark hold kubelet kubeadm kubectl
swapoff -a

echo "$LBIP $LBDNS" >> /etc/hosts
IP=$(ifconfig enp0s8 | grep inet | awk '{print $2}' | cut -d':' -f2)
echo "KUBELET_EXTRA_ARGS=\"--node-ip=$IP --cluster-dns=$CLUSTERIP\"" > /etc/default/kubelet
systemctl restart kubelet

echo $HOSTNAME | grep -q 'master'
# Master Node
if [ $? -eq 0 ]; then
  # Init kubeadm
  if [ "$HOSTNAME" == "master-1" ]; then
    kubeadm init --config=/vagrant/weave/kubeadm-config.yaml | tee /vagrant/shared/kubeadm-init.log
  else
    # Import from shared dir
    mkdir -p /etc/kubernetes/pki/etcd
    cp /vagrant/shared/kubernetes/pki/ca.crt /etc/kubernetes/pki/
    cp /vagrant/shared/kubernetes/pki/ca.key /etc/kubernetes/pki/
    cp /vagrant/shared/kubernetes/pki/sa.pub /etc/kubernetes/pki/
    cp /vagrant/shared/kubernetes/pki/sa.key /etc/kubernetes/pki/
    cp /vagrant/shared/kubernetes/pki/front-proxy-ca.crt /etc/kubernetes/pki/
    cp /vagrant/shared/kubernetes/pki/front-proxy-ca.key /etc/kubernetes/pki/
    cp /vagrant/shared/kubernetes/pki/etcd/ca.crt /etc/kubernetes/pki/etcd/
    cp /vagrant/shared/kubernetes/pki/etcd/ca.key /etc/kubernetes/pki/etcd/
    cp /vagrant/shared/kubernetes/admin.conf /etc/kubernetes/
    setup_kubectl
    kubeadm init --config=/vagrant/weave/kubeadm-config.yaml
  fi
  #kubeadm init --config=/vagrant/flannel/kubeadm-config.yaml | tee /vagrant/shared/kubeadm-init.log
  setup_kubectl

  # Apply CNI
  kubectl apply -f /vagrant/weave/weave-net.yaml
  #kubectl apply -f /vagrant/flannel/flannel.yaml

  kubectl get nodes
  kubectl get po -o wide -n kube-system

  if [ "$HOSTNAME" == "master-1" ]; then
    # Export to shared dir
    rm -rf /vagrant/shared/kubernetes
    cp -R /etc/kubernetes /vagrant/shared
  fi

# Worker Node
else
  eval $(grep "kubeadm join" /vagrant/shared/kubeadm-init.log)
fi