# -*- mode: ruby -*-
# vi: set ft=ruby :

default_os = 'ubuntu'
ENV['OS'] ||= default_os

#
# CoreOS
#
Vagrant.configure('2') do |config|
  # Vagrant plugins
  %w(vagrant-ignition).each do |name|
    next if Vagrant.has_plugin? name
    Dir.chdir(Dir.home) { system "vagrant plugin install #{name}" }
  end

  update_channel = 'alpha'
  config.vm.box = "coreos-#{update_channel}"
  config.vm.box_url = "https://#{update_channel}.release.core-os.net/amd64-usr/current/coreos_production_vagrant_virtualbox.json"
  config.ssh.insert_key = false
  config.ssh.forward_agent = true

  # Masters and Workers
  (1..6).each do |i|
    name = (1..3).include?(i) ?  "master-#{i}" : "worker-#{i - 3}"
    config.vm.define name, autostart: %w(1 2 3).include?("#{i}") do |c|
      c.vm.provider 'virtualbox' do |v|
        v.check_guest_additions = false
        v.functional_vboxsf = false
        v.memory = 2048
        v.cpus = 1
        config.ignition.config_obj = v
      end
      c.vm.hostname = name
      ip = "192.168.50.#{i+10}"
      c.vm.network 'private_network', ip: ip
      c.vm.provision 'shell', path: 'provision/coreos.sh'
      c.vm.synced_folder '.', '/home/core/share', id: 'core',
        :nfs => true, :mount_options => ['nolock,vers=3,udp']
      c.ignition.enabled = true
      c.ignition.ip = ip
      c.ignition.hostname = name
      c.ignition.drive_name = "config-#{i}"
    end
  end
end if ENV['OS'] == 'coreos'

#
# Ubuntu
#
Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/bionic64'

  # Load Balancer
  config.vm.define 'lb' do |c|
    c.vm.provider 'virtualbox' do |v|
      v.cpus = 1
      v.memory = 512
    end
    c.vm.hostname = 'lb'
    c.vm.network 'private_network', ip: '192.168.50.10'
    #c.vm.network :forwarded_port, guest: 80, host: 8080
    c.vm.provision 'shell', path: 'provision/haproxy.sh'
  end

  # Masters and Workers
  (1..6).each do |i|
    name = (1..3).include?(i) ?  "master-#{i}" : "worker-#{i - 3}"
    config.vm.define name, autostart: %w(1 2 3).include?("#{i}") do |c|
      c.vm.provider 'virtualbox' do |v|
        v.cpus = 2
        v.memory = 2048
      end
      c.vm.hostname = name
      c.vm.network 'private_network', ip: "192.168.50.#{i+10}"
      c.vm.provision 'shell', path: 'provision/ubuntu.sh'
    end
  end
end if ENV['OS'] == 'ubuntu'
