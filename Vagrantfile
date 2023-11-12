# -*- mode: ruby -*-
# vi: set ft=ruby :
ENV['VAGRANT_NO_PARALLEL'] = 'yes'
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox' # virtualbox or libvirt

VAGRANT_BOX         = "bento/ubuntu-22.04"
VAGRANT_BOX_VERSION = "202309.08.0"
VAGRANT_BOX_CHECK_UPDATE = false

CPUS_MASTER_NODE    = 2
MEMORY_MASTER_NODE  = 4096

CPUS_WORKER_NODE    = 2
MEMORY_WORKER_NODE  = 16384
WORKER_NODES_COUNT  = 1

CPUS_STORAGE_NODE   = 1
MEMORY_STORAGE_NODE = 1024

IP_NW="10.0.0."
IP_START=10

Vagrant.configure("2") do |config|

    # Global
    config.vm.box = VAGRANT_BOX
    config.vm.box_check_update = VAGRANT_BOX_CHECK_UPDATE
    config.vm.box_version      = VAGRANT_BOX_VERSION
    config.ssh.forward_agent   = true
    config.vm.synced_folder ".", "/vagrant", disabled: false,
        id: "vagrant", 
        automount: true, 
        type: "nfs",
        nfs_version: 4     
    config.vm.provider :libvirt do |libvirt|
        libvirt.nested = true
        libvirt.driver = "kvm"
    end


    # Master
    config.vm.define "master" do |master|
        master.vm.hostname = "master"
        master.vm.network "private_network", ip: IP_NW + "#{IP_START}"

        # Master VirtualBox
        master.vm.provider :virtualbox do |vbox|
            vbox.name   = "master"
            vbox.cpus   = CPUS_MASTER_NODE
            vbox.memory = MEMORY_MASTER_NODE
        end

        # Master LibVirt
        master.vm.provider :libvirt do |libvirt|
            libvirt.cpus   = CPUS_MASTER_NODE
            libvirt.memory = MEMORY_MASTER_NODE
        end
    end

    # Storage
    config.vm.define "storage" do |storage|
        storage.vm.hostname   = "storage"
        storage.disksize.size = '250GB'
        storage.vm.network "private_network", ip: IP_NW + "#{IP_START + 10}"

        # Storage VirtualBox
        storage.vm.provider :virtualbox do |vbox|
            vbox.name   = "storage"
            vbox.cpus   = CPUS_STORAGE_NODE
            vbox.memory = MEMORY_STORAGE_NODE
        end

        # Storage LibVirt
        storage.vm.provider :libvirt do |libvirt|
            libvirt.cpus    = CPUS_STORAGE_NODE
            libvirt.memory  = MEMORY_STORAGE_NODE
            libvirt.machine_virtual_size = 250
        end
    end

    (1..WORKER_NODES_COUNT).each do |i|
        # Worker
        config.vm.define "worker0#{i}" do |node|
            node.vm.hostname = "worker0#{i}"
            node.vm.network "private_network", ip: IP_NW + "#{IP_START + i}"

            # Worker VirtualBox
            node.vm.provider :virtualbox do |vbox|
                vbox.name   = "worker0#{i}"
                vbox.cpus   = CPUS_WORKER_NODE
                vbox.memory = MEMORY_WORKER_NODE
            end
    
            # Worker LibVirt
            node.vm.provider :libvirt do |libvirt|
                libvirt.cpus   = CPUS_WORKER_NODE
                libvirt.memory = MEMORY_WORKER_NODE
            end

            # Parallel Provision
            if i == WORKER_NODES_COUNT
                node.vm.provision "ansible" do |ansible|
                    ansible.limit = "all"
                    ansible.playbook = "playbooks/kube-installer.yml"
                end
            end
        end
    end
end 
