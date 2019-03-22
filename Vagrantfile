# -*- mode: ruby -*-
# vi: set ft=ruby :

os =  ENV['OS'] || 'ubuntu'

Vagrant.configure('2') do |config|
  # CoreOS
  if os == 'coreos'
    %w(vagrant-ignition).each do |name|
      next if Vagrant.has_plugin? name
      Dir.chdir(Dir.home) { system "vagrant plugin install #{name}" }
    end
    config.vm.box = 'coreos-stable'
    config.vm.box_url = 'https://stable.release.core-os.net/amd64-usr/current/coreos_production_vagrant_virtualbox.json'

    config.ssh.insert_key = false
    config.ssh.forward_agent = true
    config.ignition.enabled = true
    config.check_guest_additions = false
    config.functional_vboxsf = false

    config.vm.define 'master-1' do |c|

      c.vm.provider :virtualbox do |vb, override|
        vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
        vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
        vb.gui = vm_gui
        vb.memory = vm_memory
        vb.cpus = vm_cpus
        vb.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]
        config.ignition.config_obj = vb
      end

      ip = "172.17.8.#{0+100}"
      config.vm.network :private_network, ip: ip
      config.ignition.ip = ip
      config.ignition.hostname = "master-1"
      config.ignition.drive_name = "config" + 0
    end

  # Ubuntu
  else
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
        c.vm.provision 'shell', path: 'provision/kubernetes.sh'
      end
    end
  end
end
