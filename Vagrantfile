# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'getoptlong'

ENV['VAGRANT_NO_PARALLEL'] = 'yes'
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox' # virtualbox or libvirt

VAGRANT_BOX         = "bento/ubuntu-22.04"
VAGRANT_BOX_VERSION = "202309.08.0"
VAGRANT_BOX_CHECK_UPDATE = false

CPUS_MASTER_NODE    = 2
MEMORY_MASTER_NODE  = 2048

CPUS_WORKER_NODE    = 2
MEMORY_WORKER_NODE  = 4096
WORKER_NODES_COUNT  = 2
WORKER_ONLY         = false

CPUS_STORAGE_NODE   = 1
MEMORY_STORAGE_NODE = 1024

NETWORK="10.0.0.X"
START_IP=10
STORAGE_IP=50


# Get extra arguments from cli
opts = GetoptLong.new(
    [ '--worker-only', GetoptLong::OPTIONAL_ARGUMENT ]
)
opts.ordering=(GetoptLong::REQUIRE_ORDER)
opts.each do |opt, arg|
    case opt
        when '--worker-only'
            WORKER_ONLY=true
    end
end

puts "Worker Only = #{WORKER_ONLY}"

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

    if !(WORKER_ONLY)
        # Master
        config.vm.define "master" do |master|
            ip_address = NETWORK.gsub('X', "#{START_IP}")
            master.vm.hostname = "master"
            master.vm.network "private_network", ip: ip_address #, auto_config: true
            # TODO: [KUBE-23] Ref: https://github.com/hashicorp/vagrant/issues/12984
            # master.vm.base_address = ip_address
            # master.ssh.host = ip_address
            # master.ssh.port = 22

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
            ip_address = NETWORK.gsub('X', "#{STORAGE_IP}")
            storage.vm.hostname   = "storage"
            storage.disksize.size = '250GB'
            storage.vm.network "private_network", ip: ip_address

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
    end

    (1..WORKER_NODES_COUNT).each do |i|
        # Worker
        config.vm.define "worker0#{i}" do |node|
            ip_address = NETWORK.gsub('X', "#{START_IP + i}")
            node.vm.hostname = "worker0#{i}"
            node.vm.network "private_network", ip: ip_address

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
                    ansible.extra_vars = {
                        worker_only: WORKER_ONLY,
                        storage_ip: NETWORK.gsub('X', "#{STORAGE_IP}"),
                        system: { 
                            domain: "jackson.com",
                        },
                        vagrant: {
                            config_path: "/vagrant/configs",
                            shared_config_path: "/data/configs",
                        }
                        
                    }
                end
            end
        end
    end
end 
