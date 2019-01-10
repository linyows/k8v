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
apt-mark hold kubelet kubeadm kubectl
swapoff -a

IP=$(ifconfig enp0s8 | grep inet | awk '{print $2}' | cut -d':' -f2)
echo "KUBELET_EXTRA_ARGS=\"--node-ip=$IP --cluster-dns=10.244.0.10\"" > /etc/default/kubelet
systemctl restart kubelet

if [ "$HOSTNAME" == "master-1" ]; then
  # Init kubeadm
  kubeadm init --config=/vagrant/kubeadm-config.yaml | tee /vagrant/kubeadm-init.log

  # Setup kubectl
  mkdir -p $HOME/.kube
  cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  mkdir -p /home/vagrant/.kube
  cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
  chown -R vagrant:vagrant /home/vagrant/.kube

  # Apply CNI
  kubectl apply -f /vagrant/net.yaml
  #kubectl apply -f /vagrant/kube-flannel.yml

  kubectl get nodes
  kubectl get po -o wide -n kube-system

  # Export to shared dir
  rm -rf /vagrant/etc
  cp -R /etc/kubernetes /vagrant/etc
else
  echo $HOSTNAME | grep -q 'master'
  if [ $? -eq 0 ]; then
    # Import from shared dir
    mkdir -p /etc/kubernetes/pki/etcd
    cp /vagrant/etc/pki/ca.crt /etc/kubernetes/pki/
    cp /vagrant/etc/pki/ca.key /etc/kubernetes/pki/
    cp /vagrant/etc/pki/sa.pub /etc/kubernetes/pki/
    cp /vagrant/etc/pki/sa.key /etc/kubernetes/pki/
    cp /vagrant/etc/pki/front-proxy-ca.crt /etc/kubernetes/pki/
    cp /vagrant/etc/pki/front-proxy-ca.key /etc/kubernetes/pki/
    cp /vagrant/etc/pki/etcd/ca.crt /etc/kubernetes/pki/etcd/
    cp /vagrant/etc/pki/etcd/ca.key /etc/kubernetes/pki/etcd/
    cp /vagrant/etc/admin.conf /etc/kubernetes/
    cmd=$(grep "kubeadm join" /vagrant/kubeadm-init.log)
    eval "$cmd --experimental-control-plane"
  else
    eval $(grep "kubeadm join" /vagrant/kubeadm-init.log)
  fi
fi
