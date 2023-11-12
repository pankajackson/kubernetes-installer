# -*- mode: ruby -*-
# vi: set ft=ruby :
NUM_WORKER_NODES=3
IP_NW="10.0.0."
IP_START=10

Vagrant.configure("2") do |config|

    config.vm.box = "bento/ubuntu-22.04"
    config.vm.box_check_update = true

    config.vm.define "master" do |master|
        master.vm.hostname = "master"
        master.vm.network "private_network", ip: IP_NW + "#{IP_START}"
        master.vm.provider "virtualbox" do |vb|
            vb.memory = 4096
            vb.cpus = 2
        end
    end

    config.vm.define "storage" do |storage|
        storage.vm.hostname = "storage"
        storage.vm.network "private_network", ip: IP_NW + "#{IP_START + 10}"
        storage.vm.provider "virtualbox" do |vb|
            vb.memory = 1024
            vb.cpus = 1
        end
        storage.disksize.size = '250GB'
    end

    (1..NUM_WORKER_NODES).each do |i|
        config.vm.define "worker0#{i}" do |node|
            node.vm.hostname = "worker0#{i}"
            node.vm.network "private_network", ip: IP_NW + "#{IP_START + i}"
            node.vm.provider "virtualbox" do |vb|
                vb.memory = 16384
                vb.cpus = 2
            end

            # Parallel Provision
            if i == NUM_WORKER_NODES
                node.vm.provision "ansible" do |ansible|
                    ansible.limit = "all"
                    ansible.playbook = "playbooks/kube-installer.yml"
                end
            end
        end
    end
end 
