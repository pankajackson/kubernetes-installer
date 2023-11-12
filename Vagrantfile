# -*- mode: ruby -*-
# vi: set ft=ruby :
ENV['VAGRANT_NO_PARALLEL'] = 'yes'
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt' # virtualbox

VAGRANT_BOX         = "bento/ubuntu-22.04"
VAGRANT_BOX_VERSION = "202309.08.0" #"4.2.10"
VAGRANT_BOX_CHECK_UPDATE = false

CPUS_MASTER_NODE    = 2
MEMORY_MASTER_NODE  = 4096

CPUS_WORKER_NODE    = 2
MEMORY_WORKER_NODE  = 16384
WORKER_NODES_COUNT  = 1

CPUS_STORAGE_NODE = 1
MEMORY_STORAGE_NODE  = 1024

IP_NW="10.0.0."
IP_START=10

Vagrant.configure("2") do |config|

    config.vm.box = VAGRANT_BOX
    config.vm.box_check_update = VAGRANT_BOX_CHECK_UPDATE
    config.vm.box_version       = VAGRANT_BOX_VERSION
    config.vm.synced_folder ".", "/vagrant"

    config.vm.define "master" do |master|
        master.vm.hostname = "master"
        master.vm.network "private_network", ip: IP_NW + "#{IP_START}"
        master.vm.synced_folder ".", "/vagrant", disabled: false,
            id: "vagrant", 
            automount: true, 
            type: "nfs",
            nfs_version: 4
        master.vm.provider :virtualbox do |v|
            v.name    = "master"
            v.memory  = MEMORY_MASTER_NODE
            v.cpus    = CPUS_MASTER_NODE
        end
        master.vm.provider :libvirt do |v|
            v.memory  = MEMORY_MASTER_NODE
            v.cpus    = CPUS_MASTER_NODE
            v.nested  = true
            v.driver = "kvm"
        end
    end

    config.vm.define "storage" do |storage|
        storage.vm.hostname = "storage"
        storage.vm.network "private_network", ip: IP_NW + "#{IP_START + 10}"
        storage.vm.synced_folder ".", "/vagrant", disabled: false,
            id: "vagrant", 
            automount: true, 
            type: "nfs",
            nfs_version: 4
        storage.vm.provider :virtualbox do |v|
            v.name    = "storage"
            v.memory  = MEMORY_STORAGE_NODE
            v.cpus    = CPUS_STORAGE_NODE
        end
        storage.vm.provider :libvirt do |v|
            v.memory  = MEMORY_STORAGE_NODE
            v.cpus    = CPUS_STORAGE_NODE
            v.nested  = true
            v.driver = "kvm"
            v.machine_virtual_size = 250
        end
        # storage.disksize.size = '250GB'
        # storage.vm.disk :disk, size: "250GB", name: "extra_storage"
    end

    (1..WORKER_NODES_COUNT).each do |i|
        config.vm.define "worker0#{i}" do |node|
            node.vm.hostname = "worker0#{i}"
            node.vm.network "private_network", ip: IP_NW + "#{IP_START + i}"
            node.vm.synced_folder ".", "/vagrant", disabled: false,
                id: "vagrant", 
                automount: true, 
                type: "nfs",
                nfs_version: 4
            node.vm.provider :virtualbox do |v|
                v.name    = "worker0#{i}"
                v.memory  = MEMORY_WORKER_NODE
                v.cpus    = CPUS_WORKER_NODE
            end
            node.vm.provider :libvirt do |v|
                v.memory  = MEMORY_WORKER_NODE
                v.cpus    = CPUS_WORKER_NODE
                v.nested  = true
                v.driver = "kvm"
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
