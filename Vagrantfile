# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/bionic64'
  config.vm.provider 'virtualbox' do |v|
    v.cpus = 2
    v.memory = 1024
  end

  (1..3).each do |i|
    name = i == 1 ? "master-#{i}" : "node-#{i - 1}"
    config.vm.define name do |c|
      c.vm.hostname = name
      c.vm.network 'private_network', ip: "172.16.20.#{i+10}"
      c.vm.provision 'shell', path: 'provisioner.sh'
    end
  end
end
