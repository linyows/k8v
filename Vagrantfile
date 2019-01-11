# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/bionic64'

  # Load Balancer
  config.vm.define 'lb' do |c|
    c.vm.provider 'virtualbox' do |v|
      v.cpus = 1
      v.memory = 512
    end
    c.vm.hostname = 'lb'
    c.vm.network 'private_network', ip: '172.16.20.10'
    #c.vm.network :forwarded_port, guest: 80, host: 8080
    c.vm.provision 'shell', path: 'provision/haproxy.sh'
  end

  # Masters and Workers
  (1..6).each do |i|
    name = (1..3).include?(i) ?  "master-#{i}" : "woker-#{i - 3}"
    config.vm.define name do |c|
      c.vm.provider 'virtualbox' do |v|
        v.cpus = 2
        v.memory = 2048
      end
      c.vm.hostname = name
      c.vm.network 'private_network', ip: "172.16.20.#{i+10}"
      c.vm.provision 'shell', path: 'provision/kubernetes.sh'
    end
  end
end
