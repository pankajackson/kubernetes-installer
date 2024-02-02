# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'getoptlong'

DEFAULT_NETWORK_INTERFACE = `ip route | awk '/^default/ {printf "%s", $5; exit 0}'`

ENV['VAGRANT_NO_PARALLEL'] = 'yes'
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox' # virtualbox or libvirt

VAGRANT_BOX         = "bento/ubuntu-22.04"
VAGRANT_BOX_VERSION = "202309.08.0"
VAGRANT_BOX_CHECK_UPDATE = false

MASTER_CPU      = 2
MASTER_MEMORY   = 4096

WORKER_CPU      = 2
WORKER_MEMORY   = 4096
WORKER_COUNT    = 1
WORKER_ONLY     = false

STORAGE_CPU     = 1
STORAGE_MEMORY  = 1024
STORAGE_IP      = 50

NETWORK     = "10.1.0.X"
START_IP    = 10


# Get extra arguments from cli
opts = GetoptLong.new(
    [ '--master-cpu', GetoptLong::OPTIONAL_ARGUMENT ],
    [ '--master-memory', GetoptLong::OPTIONAL_ARGUMENT ],
    [ '--worker-cpu', GetoptLong::OPTIONAL_ARGUMENT ],
    [ '--worker-memory', GetoptLong::OPTIONAL_ARGUMENT ],
    [ '--worker-count', GetoptLong::OPTIONAL_ARGUMENT ],
    [ '--worker-only', GetoptLong::OPTIONAL_ARGUMENT ],
    [ '--start-ip', GetoptLong::OPTIONAL_ARGUMENT ],
)
opts.ordering=(GetoptLong::REQUIRE_ORDER)

opts.each do |opt, arg|
    case opt
        when '--master-cpu'
            MASTER_CPU=arg.to_i
        when '--master-memory'
            MASTER_MEMORY=arg.to_i
        when '--worker-cpu'
            WORKER_CPU=arg.to_i
        when '--worker-memory'
            WORKER_MEMORY=arg.to_i
        when '--worker-count'
            WORKER_COUNT=arg.to_i
        when '--worker-only'
            WORKER_ONLY=arg.to_i
        when '--start-ip'
            START_IP=arg.to_i
    end
end

puts "Worker Only = #{WORKER_ONLY}"
puts "Default network Interface = #{DEFAULT_NETWORK_INTERFACE}"
puts "Start IP = #{START_IP}"

Vagrant.configure("2") do |config|

    # Global
    config.vm.box = VAGRANT_BOX
    config.vm.box_check_update = VAGRANT_BOX_CHECK_UPDATE
    config.vm.box_version      = VAGRANT_BOX_VERSION
    config.ssh.forward_agent   = true
    config.vm.synced_folder ".", "/vagrant", disabled: false,
        id: "vagrant", 
        automount: true
    config.vm.provider :libvirt do |libvirt|
        libvirt.nested = true
        libvirt.driver = "kvm"
    end

    if !(WORKER_ONLY)
        # Master
        config.vm.define "master" do |master|
            ip_address = NETWORK.gsub('X', "#{START_IP}")
            master.vm.hostname = "master"
            master.vm.network "public_network", bridge: DEFAULT_NETWORK_INTERFACE, ip: ip_address #, auto_config: true
            # TODO: [KUBE-23] Ref: https://github.com/hashicorp/vagrant/issues/12984
            # master.vm.base_address = ip_address
            # master.ssh.host = ip_address
            # master.ssh.port = 22

            # Master VirtualBox
            master.vm.provider :virtualbox do |vbox|
                vbox.name   = "master"
                vbox.cpus   = MASTER_CPU
                vbox.memory = MASTER_MEMORY
            end

            # Master LibVirt
            master.vm.provider :libvirt do |libvirt|
                libvirt.cpus   = MASTER_CPU
                libvirt.memory = MASTER_MEMORY
            end
        end

        # Storage
        config.vm.define "storage" do |storage|
            ip_address = NETWORK.gsub('X', "#{STORAGE_IP}")
            storage.vm.hostname   = "storage"
            storage.disksize.size = '250GB'
            storage.vm.network "public_network", bridge: DEFAULT_NETWORK_INTERFACE, ip: ip_address

            # Storage VirtualBox
            storage.vm.provider :virtualbox do |vbox|
                vbox.name   = "storage"
                vbox.cpus   = STORAGE_CPU
                vbox.memory = STORAGE_MEMORY
            end

            # Storage LibVirt
            storage.vm.provider :libvirt do |libvirt|
                libvirt.cpus    = STORAGE_CPU
                libvirt.memory  = STORAGE_MEMORY
                libvirt.machine_virtual_size = 250
            end
        end
    end

    (1..WORKER_COUNT).each do |i|
        # Worker
        config.vm.define "worker0#{i}" do |node|
            ip_address = NETWORK.gsub('X', "#{START_IP + i}")
            node.vm.hostname = "worker0#{i}"
            node.vm.network "public_network", bridge: DEFAULT_NETWORK_INTERFACE, ip: ip_address

            # Worker VirtualBox
            node.vm.provider :virtualbox do |vbox|
                vbox.name   = "worker0#{i}"
                vbox.cpus   = WORKER_CPU
                vbox.memory = WORKER_MEMORY
            end
    
            # Worker LibVirt
            node.vm.provider :libvirt do |libvirt|
                libvirt.cpus   = WORKER_CPU
                libvirt.memory = WORKER_MEMORY
            end

            # Parallel Provision
            if i == WORKER_COUNT
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
