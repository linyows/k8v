# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = 'ubuntu/xenial64'
  config.vm.provider 'virtualbox' do |v|
    v.cpus = 1
    v.memory = 1024
  end

  (1..3).each do |i|
    config.vm.define vm_name do |c|
      c.vm.hostname = i == 1 ? 'master' : "node#{i-1}"
      c.vm.network 'private_network', ip: "172.16.20.#{i+10}"
      c.vm.provision 'shell', path: 'provisioner.sh'
    end
  end
end
